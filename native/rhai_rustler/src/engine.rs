use std::sync::Mutex;

use rhai::{Dynamic, Engine};
use rustler::{Env, ResourceArc, Term};

use crate::{errors::to_error, types::from_dynamic};

pub struct EngineResource {
    pub engine: Mutex<Engine>,
}

#[rustler::nif]
fn engine_new() -> ResourceArc<EngineResource> {
    let resource = ResourceArc::new(EngineResource {
        engine: Mutex::new(Engine::new()),
    });

    resource
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
fn engine_set_fail_on_invalid_map_property(resource: ResourceArc<EngineResource>, enable: bool) {
    let mut engine = resource.engine.try_lock().unwrap();
    engine.set_fail_on_invalid_map_property(enable);
}
