use std::sync::Mutex;

use rhai::AST;
use rustler::{Resource, ResourceArc};

pub struct ASTResource {
    pub ast: Mutex<AST>,
}

#[rustler::resource_impl]
impl Resource for ASTResource {}

#[rustler::nif]
fn ast_empty() -> ResourceArc<ASTResource> {
    ResourceArc::new(ASTResource {
        ast: Mutex::new(AST::empty()),
    })
}

#[rustler::nif]
fn ast_set_source(resource: ResourceArc<ASTResource>, source: &str) {
    let mut ast = resource.ast.try_lock().unwrap();

    ast.set_source(source);
}

#[rustler::nif]
fn ast_clear_source(resource: ResourceArc<ASTResource>) {
    let mut ast = resource.ast.try_lock().unwrap();

    ast.clear_source();
}

#[rustler::nif]
fn ast_source(resource: ResourceArc<ASTResource>) -> Option<String> {
    let ast = resource.ast.try_lock().unwrap();

    ast.source().map(|s| s.to_string())
}

#[rustler::nif]
fn ast_merge(
    resource: ResourceArc<ASTResource>,
    other_resource: ResourceArc<ASTResource>,
) -> ResourceArc<ASTResource> {
    let ast = resource.ast.try_lock().unwrap();
    let other_ast = other_resource.ast.try_lock().unwrap();

    ResourceArc::new(ASTResource {
        ast: Mutex::new(ast.merge(&other_ast)),
    })
}

#[rustler::nif]
fn ast_combine(
    resource: ResourceArc<ASTResource>,
    other_resource: ResourceArc<ASTResource>,
) -> ResourceArc<ASTResource> {
    let mut ast = resource.ast.try_lock().unwrap();
    let other_ast = other_resource.ast.try_lock().unwrap().clone();

    ResourceArc::new(ASTResource {
        ast: Mutex::new(ast.combine(other_ast).clone()),
    })
}

#[rustler::nif]
fn ast_clear_functions(resource: ResourceArc<ASTResource>) {
    let mut ast = resource.ast.try_lock().unwrap();

    ast.clear_functions();
}

#[rustler::nif]
fn ast_clear_statements(resource: ResourceArc<ASTResource>) {
    let mut ast = resource.ast.try_lock().unwrap();

    ast.clear_statements();
}

#[rustler::nif]
fn ast_clone_functions_only(resource: ResourceArc<ASTResource>) -> ResourceArc<ASTResource> {
    let ast = resource.ast.try_lock().unwrap();

    ResourceArc::new(ASTResource {
        ast: Mutex::new(ast.clone_functions_only()),
    })
}

#[rustler::nif]
fn ast_has_functions(resource: ResourceArc<ASTResource>) -> bool {
    let ast = resource.ast.try_lock().unwrap();

    ast.has_functions()
}
