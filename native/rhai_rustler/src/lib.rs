mod errors;
mod types;

use std::collections::HashMap;

use rhai::{Dynamic, Engine, Scope};
use rustler::{Env, Term};

#[rustler::nif]
fn eval<'a>(
    env: Env<'a>,
    expression: &str,
    expression_scope: HashMap<String, Term<'a>>,
) -> Result<Term<'a>, Term<'a>> {
    // Create an 'Engine'
    let mut engine = Engine::new();
    engine.set_fail_on_invalid_map_property(true);
    let engine = engine;

    let mut scope = Scope::new();

    // Add variables to the scope
    for (k, v) in &expression_scope {
        scope.push_constant_dynamic(k, types::to_dynamic(env, v));
    }

    match engine.eval_with_scope::<Dynamic>(&mut scope, expression) {
        Ok(result) => Ok(types::from_dynamic(env, result)),

        Err(e) => Err(errors::to_error(env, *e)),
    }
}

rustler::init!("Elixir.Rhai.Native", [eval]); //, load = load);
