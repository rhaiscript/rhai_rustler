use std::sync::Mutex;

use rhai::Scope;
use rustler::{Env, ResourceArc, Term};

use crate::types::{from_dynamic, to_dynamic};

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

#[rustler::nif]
fn scope_push_constant_dynamic<'a>(
    env: Env<'a>,
    resource: ResourceArc<ScopeResource>,
    name: &str,
    value: Term<'a>,
) {
    let mut scope = resource.scope.try_lock().unwrap();
    _ = scope.push_constant_dynamic(name, to_dynamic(env, &value));
}

#[rustler::nif]
fn scope_contains(resource: ResourceArc<ScopeResource>, name: &str) -> bool {
    let scope = resource.scope.try_lock().unwrap();
    scope.contains(name)
}

#[rustler::nif]
fn scope_is_constant(resource: ResourceArc<ScopeResource>, name: &str) -> Option<bool> {
    let scope = resource.scope.try_lock().unwrap();
    scope.is_constant(name)
}

#[rustler::nif]
fn scope_get_value<'a>(
    env: Env<'a>,
    resource: ResourceArc<ScopeResource>,
    name: &str,
) -> Option<Term<'a>> {
    let scope = resource.scope.try_lock().unwrap();

    scope.get_value(name).map(|v| from_dynamic(env, v))
}

#[rustler::nif]
fn scope_clear(resource: ResourceArc<ScopeResource>) {
    let mut scope = resource.scope.try_lock().unwrap();
    scope.clear();
}

#[rustler::nif]
fn scope_clone_visible(resource: ResourceArc<ScopeResource>) -> ResourceArc<ScopeResource> {
    let scope = resource.scope.try_lock().unwrap();
    ResourceArc::new(ScopeResource {
        scope: Mutex::new(scope.clone_visible()),
    })
}
