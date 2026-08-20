@meta |
  version:0.9.9
  file:public/js/strawnode_app/strawnode_modules/type.js
  lines:310
  deps:none
  author:saz aka True
  globalAliases:Type Pkg
  pattern:OOP class system with packages domains mixins interfaces statics
|
@core |
  define:Type.define(properties, ...mixins) => constructor
  properties:keys:constructor inherits mixins interfaces statics domain pkg protoinit
  statics.initialize:called once after static setup
  protoinit:def called after prototype setup
  pkg:'@' prefix marks interface
  domain:Type.appdomain (window or this)
  return:constructor with .slot metadata
  make:Type.make(constructor, ...args) => instance
  purpose:validates all interface methods exist on prototype
  is:Type.is(instance, definition) => boolean
  of:Type.of(instance, typestr) => boolean|string
  format:Type.format(type) => resolved type
  accepts:class with .slot hashcode string name array undefined
  hash:Type.hash(qname) => number
  implement:Type.implement(definition, interfaces) => definition
  throws:NotImplementedMethodException
|
@packages |
  Pkg.register:path string definition function => definition
  purpose:lookup by qualified name in PKG registry
  auto:runs Type.define if definition lacks .slot
  Pkg.write:path string obj function array => any
  pattern:Pkg.write('org.pkg', function(path) { Type.define({...}) })
  arrays:recursively writes each element under same path
  nesting:temporarily sets Type.hackpath for namespace scoping
  Pkg.definition:path string => function|undefined
  fallback:checks Type.globals
|
@slots |
  description:every Type.define result gets a .slot metadata object
  fields:|
  appdomain:domain object (window)
  qualifiedclassname:short name like 'Step'
  pkg:package path like 'step'
  fullqualifiedclassname:full name like 'step::Step'
  hashcode:integer hash code
  isinterface:true if pkg contained '@'
  model:copy of original properties object
  toString:returns 'Type@{qname}Definition'
  defToString:returns '[class {qname}]' or '[interface {qname}]'
|
@lookup |
  getDefinitionByName:Type.getDefinitionByName(qname, domain?) => function
  search:order:domain || Type.appdomain then Type.globals then DEFS[hash]
  getDefinitionByHash:Type.getDefinitionByHash(hashcode) => function
  purpose:returns entire DEFS registry
  getAllDefinitions:Type.getAllDefinitions() => object
  definition:Type.definition(qname, domain?) => function
  alias:for getDefinitionByName
  getType:Type.getType(type) => slot object
  returns:'unregistered_type' if not found
  getQualifiedClassName:Type.getQualifiedClassName(type) => string
  getFullQualifiedClassName:Type.getFullQualifiedClassName(type) => string
|
@utils |
  merge:Type.merge(from, into, nocheck?) => into
  purpose:run all registered custom checks
  keep_r:constructor|hashCode|hashcode|toString|model|pkg|(app)?domain
  destructive:deletes source props unless nocheck=true
  globals:Type.globals => {}
  appdomain:Type.appdomain => window
  internals:Type.internals => {}
  customDefinitionChecks:Type.customDefinitionChecks(closure) => void
  receives:(properties, def)
  customize:Type.customize(properties, def) => properties
|
@usage |
  simpleClass:|
  var:P = Type.definition('org.libspark.straw.proxies::Proxy');
  inherits:Animal,
  constructor:function Cat(n) { Cat.base.call(this, n); },
  speak:function() { return 'meow'; }
  statics:{SPACE:,initialize:function() { }}
  pkg:'@shape',
  domain:Type.appdomain,
  packages:|
  Pkg.write('org.libspark.betweenjs',:function(path) {
  Pkg.write('core',:function(path) {
  Type.define({:... });
  interface:|
  draw:function() { /* ... */ }
  interfaces:[IShape],
  resolution:|
|
