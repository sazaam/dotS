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
    properties keys:constructor inherits mixins interfaces statics domain pkg protoinit
    statics.initialize:called once after static setup
    protoinit:def called after prototype setup
    pkg:'@' prefix marks interface
    domain:Type.appdomain (window or this)
    return:constructor with .slot metadata
  make:Type.make(constructor, ...args) => instance
    purpose:factory without new keyword
  is:Type.is(instance, definition) => boolean
    purpose:instanceof wrapper
  of:Type.of(instance, typestr) => boolean|string
    purpose:typeof wrapper
  format:Type.format(type) => resolved type
    accepts:class with .slot hashcode string name array undefined
  hash:Type.hash(qname) => number
    purpose:Java-style hashCode from qualified name string
  implement:Type.implement(definition, interfaces) => definition
    purpose:validates all interface methods exist on prototype
    throws:NotImplementedMethodException
|

@packages |
  Pkg.register:path string definition function => definition
    purpose:register class in PKG registry by qualified name
    auto:runs Type.define if definition lacks .slot
  Pkg.write:path string obj function array => any
    purpose:high-level registration with nesting
    pattern:Pkg.write('org.pkg', function(path) { Type.define({...}) })
    arrays:recursively writes each element under same path
    nesting:temporarily sets Type.hackpath for namespace scoping
  Pkg.definition:path string => function|undefined
    purpose:lookup by qualified name in PKG registry
    fallback:checks Type.globals
|

@slots |
  description:every Type.define result gets a .slot metadata object
  fields:|
    appdomain:the domain object (window)
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
    search order:domain || Type.appdomain then Type.globals then DEFS[hash]
  getDefinitionByHash:Type.getDefinitionByHash(hashcode) => function
    purpose:direct lookup in DEFS registry
  getAllDefinitions:Type.getAllDefinitions() => object
    purpose:returns entire DEFS registry
  definition:Type.definition(qname, domain?) => function
    alias:for getDefinitionByName
  getType:Type.getType(type) => slot object
    returns:'unregistered_type' if not found
  getQualifiedClassName:Type.getQualifiedClassName(type) => string
  getFullQualifiedClassName:Type.getFullQualifiedClassName(type) => string
|

@utils |
  merge:Type.merge(from, into, nocheck?) => into
    purpose:transfer properties skipping keep_r matched names
    keep_r:constructor|hashCode|hashcode|toString|model|pkg|(app)?domain
    destructive:deletes source props unless nocheck=true
  globals:Type.globals => {}
    purpose:public registry for globally-available type definitions
  appdomain:Type.appdomain => window
    purpose:global domain for type registration
  internals:Type.internals => {}
    purpose:reserved namespace for framework use
  customDefinitionChecks:Type.customDefinitionChecks(closure) => void
    purpose:register validation/transformation closures
    receives:(properties, def)
  customize:Type.customize(properties, def) => properties
    purpose:run all registered custom checks
|

@usage |
  simpleClass:|
    var Cat = Type.define({
      inherits: Animal,
      constructor: function Cat(n) { Cat.base.call(this, n); },
      speak: function() { return 'meow'; }
    });
  statics:|
    var StringUtil = Type.define({
      pkg: 'utils::StringUtil',
      domain: Type.appdomain,
      statics: { SPACE: ' ', initialize: function() { } }
    });
  packages:|
    Pkg.write('org.libspark.betweenjs', function(path) {
      Pkg.write('core', function(path) {
        Type.define({ ... });
      });
    });
  interface:|
    var IShape = Type.define({
      pkg: '@shape',
      draw: function() {}
    });
    var Circle = Type.define({
      interfaces: [IShape],
      draw: function() { /* ... */ }
    });
  resolution:|
    var P = Type.definition('org.libspark.straw.proxies::Proxy');
|

@quirks |
  destructiveRetrieve:retrieve() removes reserved props from definition object before merging
  zeroDeps:self-contained with no external dependencies
  superCalls:ClassName.base.apply(this, arguments) pattern
  hashAlgorithm:32-bit integer overflow Java-style h = 31 * ((h << 33) - h) + charCode
  twoCopies:browser UMD version and Node CommonJS version at routes/type.js
  naming:'pkg::ClassName' format with :: separator
