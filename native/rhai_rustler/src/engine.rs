use std::sync::{Mutex, RwLock};

use rhai::{Dynamic, Engine};
use rustler::{Encoder, Env, ResourceArc, Term};

use crate::{
    ast::ASTResource,
    errors::{atoms, to_error},
    types::from_dynamic,
};

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
) -> Result<Term<'a>, Term<'a>> {
    let engine = resource.engine.try_lock().unwrap();

    match engine.eval::<Dynamic>(script) {
        Ok(result) => Ok(from_dynamic(env, result)),
        Err(e) => Err(to_error(env, *e)),
    }
}

#[rustler::nif]
fn engine_compile<'a>(
    env: Env<'a>,
    resource: ResourceArc<EngineResource>,
    script: &str,
) -> Result<ResourceArc<ASTResource>, Term<'a>> {
    let engine = resource.engine.try_lock().unwrap();

    match engine.compile(script) {
        Ok(result) => {
            let ast_resource = ResourceArc::new(ASTResource {
                ast: RwLock::new(result),
            });
            Ok(ast_resource)
        }
        Err(_) => Err((atoms::parsing(), "parsing error".to_string().encode(env)).encode(env)),
    }
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
