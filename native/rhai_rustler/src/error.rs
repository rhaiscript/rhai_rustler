use thiserror::Error;

use rhai::{EvalAltResult, ParseError};
use rustler::{Encoder, Env, Term};
mod atoms {
    rustler::atoms! {
        system,
        parsing,
        variable_exists,
        forbidden_variable,
        variable_not_found,
        property_not_found,
        index_not_found,
        function_not_found,
        module_not_found,
        in_function_call,
        in_module,
        unbound_this,
        mismatch_data_type,
        mismatch_output_type,
        indexing_type,
        array_bounds,
        string_bounds,
        bit_field_bounds,
        for_atom = "for",
        data_race,
        assignment_to_constant,
        dot_expr,
        arithmetic,
        too_many_operations,
        too_many_modules,
        stack_overflow,
        data_too_large,
        terminated,
        custom_syntax,
        runtime,
        non_pure_method_call_on_constant,
    }
}

#[derive(Error, Debug)]
pub enum RhaiRustlerError {
    #[error("Error in evaluation: {0}")]
    EvalAltResult(#[from] Box<EvalAltResult>),
    #[error("Error when parsing a script: {0}")]
    ParseError(#[from] ParseError),
}

impl Encoder for RhaiRustlerError {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        match self {
            RhaiRustlerError::EvalAltResult(err) => {
                let error_atom = match err.unwrap_inner() {
                    EvalAltResult::ErrorSystem(_, _) => atoms::system(),
                    EvalAltResult::ErrorParsing(_, _) => atoms::parsing(),
                    EvalAltResult::ErrorVariableExists(_, _) => atoms::variable_exists(),
                    EvalAltResult::ErrorForbiddenVariable(_, _) => atoms::forbidden_variable(),
                    EvalAltResult::ErrorVariableNotFound(_, _) => atoms::variable_not_found(),
                    EvalAltResult::ErrorPropertyNotFound(_, _) => atoms::property_not_found(),
                    EvalAltResult::ErrorIndexNotFound(_, _) => atoms::index_not_found(),
                    EvalAltResult::ErrorFunctionNotFound(_, _) => atoms::function_not_found(),
                    EvalAltResult::ErrorModuleNotFound(_, _) => atoms::module_not_found(),
                    EvalAltResult::ErrorInFunctionCall(_, _, _, _) => atoms::in_function_call(),
                    EvalAltResult::ErrorInModule(_, _, _) => atoms::in_module(),
                    EvalAltResult::ErrorUnboundThis(_) => atoms::unbound_this(),
                    EvalAltResult::ErrorMismatchDataType(_, _, _) => atoms::mismatch_data_type(),
                    EvalAltResult::ErrorMismatchOutputType(_, _, _) => {
                        atoms::mismatch_output_type()
                    }
                    EvalAltResult::ErrorIndexingType(_, _) => atoms::indexing_type(),
                    EvalAltResult::ErrorArrayBounds(_, _, _) => atoms::array_bounds(),
                    EvalAltResult::ErrorStringBounds(_, _, _) => atoms::string_bounds(),
                    EvalAltResult::ErrorBitFieldBounds(_, _, _) => atoms::bit_field_bounds(),
                    EvalAltResult::ErrorFor(_) => atoms::for_atom(),
                    EvalAltResult::ErrorDataRace(_, _) => atoms::data_race(),
                    EvalAltResult::ErrorAssignmentToConstant(_, _) => {
                        atoms::assignment_to_constant()
                    }
                    EvalAltResult::ErrorDotExpr(_, _) => atoms::dot_expr(),
                    EvalAltResult::ErrorArithmetic(_, _) => atoms::arithmetic(),
                    EvalAltResult::ErrorTooManyOperations(_) => atoms::too_many_operations(),
                    EvalAltResult::ErrorTooManyModules(_) => atoms::too_many_modules(),
                    EvalAltResult::ErrorStackOverflow(_) => atoms::stack_overflow(),
                    EvalAltResult::ErrorDataTooLarge(_, _) => atoms::data_too_large(),
                    EvalAltResult::ErrorTerminated(_, _) => atoms::terminated(),
                    EvalAltResult::ErrorCustomSyntax(_, _, _) => atoms::custom_syntax(),
                    EvalAltResult::ErrorRuntime(_, _) => atoms::runtime(),
                    EvalAltResult::ErrorNonPureMethodCallOnConstant(_, _) => {
                        atoms::non_pure_method_call_on_constant()
                    }
                    _ => panic!("Not an error"),
                };

                make_reason_tuple(env, error_atom, err.to_string())
            }
            RhaiRustlerError::ParseError(err) => {
                make_reason_tuple(env, atoms::parsing(), err.to_string())
            }
        }
    }
}

fn make_reason_tuple(env: Env, atom: rustler::types::atom::Atom, err_str: String) -> Term {
    (atom, err_str.encode(env)).encode(env)
}
