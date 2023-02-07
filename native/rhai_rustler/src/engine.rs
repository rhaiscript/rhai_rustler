use std::sync::Mutex;

use rhai::{Dynamic, Engine};
use rustler::ResourceArc;

pub struct EngineResource {
    pub engine: Mutex<Engine>,
}

#[rustler::nif]
fn new() -> ResourceArc<EngineResource> {
    let resource = ResourceArc::new(EngineResource {
        engine: Mutex::new(Engine::new()),
    });

    resource
}

#[rustler::nif]
fn set_fail_on_invalid_map_property(resource: ResourceArc<EngineResource>, flag: bool) {
    let mut engine = resource.engine.try_lock().unwrap();
    engine.set_fail_on_invalid_map_property(flag);
}

#[rustler::nif]
fn eval(resource: ResourceArc<EngineResource>, expression: &str) {
    let engine = resource.engine.try_lock().unwrap();
    let result = engine.eval::<Dynamic>(expression);

    dbg!(result);
}
