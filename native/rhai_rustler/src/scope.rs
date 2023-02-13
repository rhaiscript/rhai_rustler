use std::sync::Mutex;

use rhai::Scope;
use rustler::{Env, ResourceArc, Term};

use crate::types::to_dynamic;

pub struct ScopeResource {
    pub scope: Mutex<Scope<'static>>,
}

#[rustler::nif]
fn scope_new() -> ResourceArc<ScopeResource> {
    ResourceArc::new(ScopeResource {
        scope: Mutex::new(Scope::new()),
    })
}

#[rustler::nif]
fn scope_push_dynamic<'a>(
    env: Env<'a>,
    resource: ResourceArc<ScopeResource>,
    name: &str,
    value: Term<'a>,
) {
    let mut scope = resource.scope.try_lock().unwrap();
    _ = scope.push_dynamic(name, to_dynamic(env, &value));
}
