use std::collections::HashMap;

use rhai::Dynamic;
use rustler::{types::tuple::get_tuple, Encoder, Env, Term, TermType};

pub fn from_dynamic(env: Env, value: Dynamic) -> Term {
    match value.type_name() {
        "()" => rustler::types::atom::nil().to_term(env),
        "i64" => value.cast::<i64>().encode(env),
        "f64" => value.cast::<f64>().encode(env),
        "bool" => value.cast::<bool>().encode(env),
        "string" => value.cast::<String>().encode(env),
        "char" => value.cast::<char>().to_string().encode(env),
        "array" => value
            .cast::<Vec<Dynamic>>()
            .into_iter()
            .map(|v| from_dynamic(env, v))
            .collect::<Vec<Term>>()
            .encode(env),
        "map" => {
            let mut map: HashMap<String, Term> = HashMap::new();
            for (k, v) in value.cast::<rhai::Map>() {
                map.insert(k.into(), from_dynamic(env, v));
            }
            map.encode(env)
        }
        _ => ().encode(env),
    }
}

pub fn to_dynamic<'a>(env: Env<'a>, term: &Term<'a>) -> Dynamic {
    match Term::get_type(*term) {
        rustler::TermType::Binary => term
            .decode::<String>()
            .map(Dynamic::from)
            .expect("get_type() returned Binary but could not decode as string."),

        rustler::TermType::Atom => term
            .decode::<bool>()
            .map(Dynamic::from)
            .or_else(|_| {
                if *term == rustler::types::atom::nil().to_term(env) {
                    Ok(Dynamic::from(()))
                } else {
                    term.atom_to_string().map(Dynamic::from)
                }
            })
            .expect("get_type() returned Atom but could not decode as string, boolean or empty."),
        TermType::EmptyList => Dynamic::from(Vec::<Dynamic>::new()),
        TermType::Exception => Dynamic::from(()),
        TermType::Fun => Dynamic::from(()),
        TermType::List => {
            let items: Vec<Dynamic> = term
                .decode::<Vec<Term>>()
                .expect("get_type() returned List but could not decode as list.")
                .iter()
                .map(|item| to_dynamic(env, item))
                .collect();

            Dynamic::from_array(items)
        }
        TermType::Map => {
            let mut object_map = rhai::Map::new();

            for (k, v) in term
                .decode::<HashMap<String, Term>>()
                .expect("get_type() returned Number but could not decod Hashmap.")
            {
                object_map.insert(k.into(), to_dynamic(env, &v));
            }
            Dynamic::from(object_map)
        }
        TermType::Number => term
            .decode::<i64>()
            .map(Dynamic::from)
            .or_else(|_| term.decode::<f64>().map(Dynamic::from))
            .expect("get_type() returned Number but could not decode as integer or float."),

        TermType::Pid => Dynamic::from(()),
        TermType::Port => Dynamic::from(()),
        TermType::Ref => Dynamic::from(()),
        TermType::Tuple => {
            let items: Vec<Dynamic> = get_tuple(*term)
                .expect("get_type() returned Tuple but could not decode as list.")
                .iter()
                .map(|item| to_dynamic(env, item))
                .collect();

            Dynamic::from(items)
        }

        TermType::Unknown => Dynamic::from(()),
    }
}
