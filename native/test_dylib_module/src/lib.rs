pub mod api;

use rhai_dylib::rhai::{config::hashing::set_hashing_seed, exported_module, Module, Shared};

#[allow(improper_ctypes_definitions)]
#[no_mangle]
pub extern "C" fn module_entrypoint() -> Shared<Module> {
    if let Err(value) = set_hashing_seed(Some([1, 3, 3, 7])) {
        if value != Some([1, 3, 3, 7]) {
            panic!("ahash seed was already set with value: {value:?}");
        }
    }

    exported_module!(api::my_plugin_api).into()
}

rustler::init!("Elixir.Rhai.TestDylibModule");
