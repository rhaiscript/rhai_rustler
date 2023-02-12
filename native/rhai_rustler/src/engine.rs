use std::sync::{Mutex, RwLock};

use rhai::{Dynamic, Engine};
use rustler::{Env, ResourceArc, Term};

use crate::{ast::ASTResource, error::RhaiRustlerError, types::from_dynamic};

pub struct EngineResource {
    pub engine: Mutex<Engine>,
}

#[rustler::nif]
fn engine_new() -> ResourceArc<EngineResource> {
    ResourceArc::new(EngineResource {
        engine: Mutex::new(Engine::new()),
    })
}

#[rustler::nif]
fn engine_eval<'a>(
    env: Env<'a>,
    resource: ResourceArc<EngineResource>,
    script: &str,
) -> Result<Term<'a>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let result = engine.eval::<Dynamic>(script)?;

    Ok(from_dynamic(env, result))
}

#[rustler::nif]
fn engine_compile(
    resource: ResourceArc<EngineResource>,
    script: &str,
) -> Result<ResourceArc<ASTResource>, RhaiRustlerError> {
    let engine = resource.engine.try_lock().unwrap();
    let ast = engine.compile(script)?;

    let ast_resource = ResourceArc::new(ASTResource {
        ast: RwLock::new(ast),
    });

    Ok(ast_resource)
}

#[rustler::nif]
fn engine_set_fail_on_invalid_map_property(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();

    engine.set_fail_on_invalid_map_property(enable);
}

#[rustler::nif]
fn engine_fail_on_invalid_map_property(resource: ResourceArc<EngineResource>) -> bool {
    let engine = resource.engine.try_lock().unwrap();

    engine.fail_on_invalid_map_property()
}
