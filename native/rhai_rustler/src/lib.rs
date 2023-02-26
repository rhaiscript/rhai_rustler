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
        engine_run,
        engine_run_with_scope,
        engine_set_fail_on_invalid_map_property,
        engine_fail_on_invalid_map_property,
        engine_set_max_array_size,
        engine_max_array_size,
        engine_set_allow_anonymous_fn,
        engine_allow_anonymous_fn,
        engine_set_allow_if_expression,
        engine_allow_if_expression,
        engine_set_allow_loop_expressions,
        engine_allow_loop_expressions,
        engine_set_allow_looping,
        engine_allow_looping,
        engine_set_allow_shadowing,
        engine_allow_shadowing,
        engine_set_allow_statement_expression,
        engine_allow_statement_expression,
        engine_set_allow_switch_expression,
        engine_allow_switch_expression,
        engine_set_fast_operators,
        engine_fast_operators,
        engine_set_max_call_levels,
        engine_max_call_levels,
        engine_set_max_expr_depths,
        engine_max_expr_depth,
        engine_max_function_expr_depth,
        engine_set_max_map_size,
        engine_max_map_size,
        engine_set_max_modules,
        engine_max_modules,
        engine_set_max_operations,
        engine_max_operations,
        engine_set_max_string_size,
        engine_max_string_size,
        engine_set_strict_variables,
        engine_strict_variables,
        // scope
        scope_new,
        scope_with_capacity,
        scope_push_dynamic,
        scope_push_constant_dynamic,
        scope_contains,
        scope_is_constant,
        scope_get_value,
        scope_clear,
        scope_clone_visible,
        scope_is_empty,
        scope_len,
        scope_remove,
        scope_rewind,
        scope_pop,
        scope_set_value,
        scope_set_alias,
        scope_set_or_push,
        scope_iter_collect
    ],
    load = load
);
