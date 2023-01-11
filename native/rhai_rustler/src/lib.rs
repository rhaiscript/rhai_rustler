mod errors;
mod types;

use std::collections::HashMap;

use rhai::{Dynamic, Engine, Scope, ImmutableString};
use rustler::{Env, Term};

use version_compare::{compare_to, Cmp};

fn version_eq(left: ImmutableString, right: ImmutableString) -> bool {
    compare_versions(left, right, Cmp::Eq)
}

fn version_ne(left: ImmutableString, right: ImmutableString) -> bool {
    compare_versions(left, right, Cmp::Ne)
}

fn version_lt(left: ImmutableString, right: ImmutableString) -> bool {
    compare_versions(left, right, Cmp::Lt)
}

fn version_le(left: ImmutableString, right: ImmutableString) -> bool {
    compare_versions(left, right, Cmp::Le)
}

fn version_ge(left: ImmutableString, right: ImmutableString) -> bool {
    compare_versions(left, right, Cmp::Ge)
}

fn version_gt(left: ImmutableString, right: ImmutableString) -> bool {
    compare_versions(left, right, Cmp::Gt)
}

fn compare_versions(left: ImmutableString, right: ImmutableString, comparison: Cmp) -> bool {
    match compare_to(left, right, comparison) {
        Ok(true) => true,
        Ok(false) => false,
        Err(_) => false
    }
}
#[rustler::nif]
fn eval<'a>(
    env: Env<'a>,
    expression: &str,
    expression_scope: HashMap<String, Term<'a>>,
) -> Result<Term<'a>, Term<'a>> {
    // Create an 'Engine'
    let mut engine = Engine::new();
    engine.set_fail_on_invalid_map_property(true);

    engine.register_fn("version_eq", version_eq);
    engine.register_fn("version_ne", version_ne);
    engine.register_fn("version_lt", version_lt);
    engine.register_fn("version_le", version_le);
    engine.register_fn("version_gt", version_gt);
    engine.register_fn("version_ge", version_ge);

    let mut scope = Scope::new();

    // Add variables to the scope
    for (k, v) in &expression_scope {
        scope.push_dynamic(k, types::to_dynamic(env, v));
    }

    match engine.eval_with_scope::<Dynamic>(&mut scope, expression) {
        Ok(result) => Ok(types::from_dynamic(env, result)),

        Err(e) => Err(errors::to_error(env, *e)),
    }
}

rustler::init!("Elixir.Rhai.Native", [eval]); //, load = load);
