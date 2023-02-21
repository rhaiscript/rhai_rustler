use std::sync::Mutex;

use rhai::Scope;
use rustler::{Encoder, Env, ResourceArc, Term};

use crate::{
    error::{RhaiRustlerError, ScopeError},
    types::{from_dynamic, to_dynamic},
};

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
fn scope_with_capacity(capacity: usize) -> ResourceArc<ScopeResource> {
    ResourceArc::new(ScopeResource {
        scope: Mutex::new(Scope::with_capacity(capacity)),
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

#[rustler::nif]
fn scope_is_empty(resource: ResourceArc<ScopeResource>) -> bool {
    let scope = resource.scope.try_lock().unwrap();
    scope.is_empty()
}

#[rustler::nif]
fn scope_len(resource: ResourceArc<ScopeResource>) -> usize {
    let scope = resource.scope.try_lock().unwrap();
    scope.len()
}

#[rustler::nif]
fn scope_remove<'a>(
    env: Env<'a>,
    resource: ResourceArc<ScopeResource>,
    name: &str,
) -> Option<Term<'a>> {
    let mut scope = resource.scope.try_lock().unwrap();
    scope.remove(name).map(|v| from_dynamic(env, v))
}

#[rustler::nif]
fn scope_rewind(resource: ResourceArc<ScopeResource>, size: usize) {
    let mut scope = resource.scope.try_lock().unwrap();
    _ = scope.rewind(size);
}

#[rustler::nif]
fn scope_iter_collect<'a>(env: Env<'a>, resource: ResourceArc<ScopeResource>) -> Vec<Term<'a>> {
    let scope = resource.scope.try_lock().unwrap();
    let value: Vec<Term<'a>> = scope
        .iter()
        .map(|(n, _, v)| (n, from_dynamic(env, v)).encode(env))
        .collect();

    value
}

#[rustler::nif]
fn scope_pop(resource: ResourceArc<ScopeResource>) -> Result<(), RhaiRustlerError> {
    let mut scope = resource.scope.try_lock().unwrap();
    if scope.is_empty() {
        return Err(ScopeError::ErrorScopeIsEmpty.into());
    }

    _ = scope.pop();
    Ok(())
}

#[rustler::nif]
fn scope_set_value<'a>(
    env: Env<'a>,
    resource: ResourceArc<ScopeResource>,
    name: &str,
    value: Term<'a>,
) -> Result<(), RhaiRustlerError> {
    let mut scope = resource.scope.try_lock().unwrap();
    if scope.is_constant(name).unwrap_or(false) {
        return Err(ScopeError::ErrorCannotUpdateValueOfConstant.into());
    }

    _ = scope.set_value(name, to_dynamic(env, &value));
    Ok(())
}
