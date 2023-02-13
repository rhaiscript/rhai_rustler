mod ast;
mod engine;
mod error;
mod scope;
mod types;

use std::collections::HashMap;

use rhai::{Dynamic, Engine, Scope};
use rustler::{Env, Term};

use crate::ast::*;
use crate::engine::*;
use crate::error::RhaiRustlerError;
use crate::scope::*;

#[rustler::nif]
fn eval<'a>(
    env: Env<'a>,
    expression: &str,
    expression_scope: HashMap<String, Term<'a>>,
) -> Result<Term<'a>, RhaiRustlerError> {
    // Create an 'Engine'
    let mut engine = Engine::new();
    engine.set_fail_on_invalid_map_property(true);
    let engine = engine;

    let mut scope = Scope::new();

    // Add variables to the scope
    for (k, v) in &expression_scope {
        scope.push_dynamic(k, types::to_dynamic(env, v));
    }

    let result = engine.eval_with_scope::<Dynamic>(&mut scope, expression)?;

    Ok(types::from_dynamic(env, result))
}

fn load(env: Env, _: Term) -> bool {
    rustler::resource!(EngineResource, env);
    rustler::resource!(ScopeResource, env);
    rustler::resource!(ASTResource, env);
    true
}

rustler::init!(
    "Elixir.Rhai.Native",
    [
        // legacy
        eval,
        // engine
        engine_compile,
        engine_new,
        engine_eval,
        engine_eval_with_scope,
        engine_set_fail_on_invalid_map_property,
        engine_fail_on_invalid_map_property,
        // scope
        scope_new,
        scope_push_dynamic,
    ],
    load = load
);
