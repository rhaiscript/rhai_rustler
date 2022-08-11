use evalexpr::Value;
use rustler::{types::tuple::get_tuple, Encoder, Env, Term, TermType};

pub fn to_value<'a>(env: Env<'a>, term: &Term<'a>) -> Value {
    match Term::get_type(*term) {
        TermType::Binary => term
            .decode()
            .map(Value::String)
            .expect("get_type() returned String but could not decode as string."),

        TermType::Number => term
            .decode::<i64>()
            .map(Value::Int)
            .or_else(|_| term.decode::<f64>().map(Value::Float))
            .expect("get_type() returned String but could not decode as integer or float."),
        TermType::Atom => term
            .decode()
            .map(Value::Boolean)
            .or_else(|_| {
                if *term == rustler::types::atom::nil().to_term(env) {
                    Ok(Value::Empty)
                } else {
                    term.atom_to_string().map(Value::String)
                }
            })
            .expect("get_type() returned Atom but could not decode as string, boolean or empty."),

        TermType::List => {
            let items = term
                .decode::<Vec<Term>>()
                .expect("get_type() returned List but could not decode as list.");

            let converted_items: Vec<Value> =
                items.iter().map(|item| to_value(env, item)).collect();

            Value::from(converted_items)
        }

        TermType::Tuple => {
            let elems =
                get_tuple(*term).expect("get_type() returned Tuple but could not decode as tuple.");
            let converted_elems: Vec<Value> =
                elems.iter().map(|elem| to_value(env, elem)).collect();

            Value::from(converted_elems)
        }

        TermType::EmptyList => Value::Tuple(vec![]),
        _ => Value::Empty,
    }
}

pub fn from_value<'a>(env: Env<'a>, value: &Value) -> Term<'a> {
    match value {
        Value::Boolean(value) => value.encode(env),
        Value::Int(value) => value.encode(env),
        Value::String(value) => value.encode(env),
        Value::Float(value) => value.encode(env),
        Value::Tuple(value) => {
            let converted_items: Vec<Term> =
                value.iter().map(|item| from_value(env, item)).collect();
            converted_items.encode(env)
        }
        Value::Empty => rustler::types::atom::nil().to_term(env),
    }
}
