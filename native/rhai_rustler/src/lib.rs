mod ast;
mod engine;
mod error;
mod scope;
mod types;

use rhai::config::hashing::set_hashing_seed;
use rustler::{Env, Term};

use crate::ast::*;
use crate::engine::*;
use crate::scope::*;

fn load(env: Env, _: Term) -> bool {
    // Set dylib ahash seed
    if let Err(value) = set_hashing_seed(Some([1, 3, 3, 7])) {
        eprintln!(
            "Failed to set ahash seed, ahash seed already set: {:?}",
            value
        );
        return false;
    }

    rustler::resource!(EngineResource, env);
    rustler::resource!(ScopeResource, env);
    rustler::resource!(ASTResource, env);

    true
}

rustler::init!("Elixir.Rhai.Native", load = load);
