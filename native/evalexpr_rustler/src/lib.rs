use evalexpr::*;
use rustler::{types::tuple::get_tuple, Encoder, Env, MapIterator, Term, TermType};

#[rustler::nif]
fn eval<'a>(env: Env<'a>, string: &str, context: Term<'a>) -> Result<Term<'a>, String> {
    let mut context_map = HashMapContext::new();

    let map = MapIterator::new(context).expect("Should be a map in the argument");

    for (k, v) in map {
        let key: String = k.decode().expect("Should be a string");

        context_map.set_value((key).to_string(), to_value(&v)).ok();
    }

    match eval_with_context(string, &context_map) {
        Ok(value) => Ok(from_value(env, &value)),
        Err(err) => Err(err.to_string()),
    }
}

fn to_value(term: &Term) -> Value {
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
            .or_else(|_| term.decode::<String>().map(Value::String))
            .or_else(|_| term.decode::<()>().map(|_| Value::Empty))
            .expect("get_type() returned Atom but could not decode as string, boolean or empty."),

        TermType::List => {
            let items = term
                .decode::<Vec<Term>>()
                .expect("get_type() returned List but could not decode as list.");

            let converted_items: Vec<Value> = items.iter().map(to_value).collect();

            Value::from(converted_items)
        }

        TermType::Tuple => {
            let elems =
                get_tuple(*term).expect("get_type() returned Tuple but could not decode as tuple.");
            let converted_elems: Vec<Value> = elems.iter().map(to_value).collect();

            Value::from(converted_elems)
        }

        TermType::EmptyList => Value::Tuple(vec![]),
        TermType::Exception => todo!(),
        TermType::Fun => todo!(),
        TermType::Map => todo!(),
        TermType::Pid => todo!(),
        TermType::Port => todo!(),
        TermType::Ref => todo!(),
        TermType::Unknown => todo!(),
    }
}

fn from_value<'a>(env: Env<'a>, value: &Value) -> Term<'a> {
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

rustler::init!("Elixir.Evalexpr", [eval]);
