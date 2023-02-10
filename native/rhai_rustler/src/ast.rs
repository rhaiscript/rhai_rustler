use std::sync::Mutex;

use rhai::AST;

pub struct ASTResource {
    pub ast: Mutex<AST>,
}
