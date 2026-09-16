# Rust Knowledge Base
@meta |topic:rust|version:1.80+|lastUpdated:2026-09-16|confidence:high|
@basics |
  toolchain:rustup, cargo
  build:cargo build
  release:cargo build --release
  run:cargo run
  test:cargo test
  check:cargo check (fast type check, no codegen)
  format:cargo fmt
  lint:cargo clippy
  doc:cargo doc --open
  new:cargo new project_name
  init:cargo init (in existing dir)
  addDep:cargo add <crate>
  main:fn main() { } entry point
  print:println!("Hello, {}!", x) / println!("{:?}", debug)
  comment:// line, /* block */, /// doc, //! inner doc
  statementEnded:semicolons after statements, NOT after expression-returning blocks
  tailExpr:last expression without ; is the return value
  immutable:variables immutable by default; add mut to reassign
  mutBound:let mut x = 5; x = 6;
  shadowing:let x = 5; let x = x + 1; (new binding, no mut needed)
|
@types |
  i32:i32 default integer (i8..i128, u8..u128, isize, usize)
  float:f64 default (f32, f64)
  bool:bool (true, false)
  char:char (4-byte Unicode scalar value)
  tuple:(i32, f64, u8); destructure let (x, y, z) = tup; access tup.0
  array:[i32; 5] same type, fixed length; let a = [3; 5] (5x 3)
  string:String (owned, growable, UTF-8)
  str:&str (string slice, borrowed)
  unit:() empty tuple, "no value"
  typeInference:let parsed: u32 = guess.trim().parse().expect("msg")
  overflow:debug builds panic on integer overflow; release wraps
  inferenceHint:type annotations often needed at binding or fn signature
|
@strings |
  create:String::new(), let s = "init"; let s = String::from("init"); let s = s.to_string()
  push:let mut s = String::new(); s.push('b'); s.push_str("ar")
  concat:let s = s1 + "-" + &s2; (takes ownership of s1)
  format:let s = format!("{}-{}", s1, s2); (no ownership transfer)
  utf8:valid UTF-8 only; may have to iterate bytes (0..len) not chars
  index:String cannot be indexed by i32 (byte positions unsafe)
  iterateByte:s.bytes()
  iterateChar:s.chars()
  len:len is BYTES, not chars
  slicing:&s[0..4] only at valid char boundaries or panic
|
@ownership |
  rule1:Each value has ONE owner
  rule2:Only one owner at a time
  rule3:When owner goes out of scope, value dropped (freed)
  move:assignment or pass moves ownership (no copy semantics)
  usagePattern:let s2 = s1; then s1 unusable (E0382), so drop which end you use
  clone:let s2 = s1.clone() (deep copy, keeps both)
  copy:numbers, bools, chars, tuples of Copy types auto-copy (no move)
  stackHeap:data on stack = Copy types; heap data moved
  fnMove:passing value INTO fn transfers ownership; can't use after
  fnReturn:returning value transfers it back out
  stackReturn:returning a reference to a stack var is an error
  drop:Drop trait runs when owner leaves scope (RAII)
  heapText:heap recs need explicit manual free (Rust does it automatically via RAII)
|
@borrowing |
  ref:&T immutable borrow (shared, many at once)
  mutRef:&mut T mutable borrow (exclusive, one at a time)
  noRefToDropped:reference cannot outlive the value it borrows
  sharedMutExclusive:can't have &mut while any & exists
  permit:while & alone exists, can read
  rareViolation:iterating over a Vec and pushing to it has no iter_mut borrow workaround (use indexes)
  fixPatterns:1) return owned data (String) 2) take ownership (not &) 3) clone 4) restructure lifetimes
  safeForFunc:borrow checker allows & when requiring &mut, but not &mut when requiring &
  ro:R = Read allowed, W = Write not, O = Ownership not (borrow permits R only)
  rw:&mut permits RwO, shared borrow permits R only
  parent:multiborrow adds child-ref: value var usable while & borrows live (O allowed)
  borrowParens:parent child ref tracked via scopes, not expr positions
deref:*x forces dereference (rarely needed in normal code)
  coercion:&&& -> && derefs implicitly when types differ by reference level
  safetyRules:safe programs never violate ownership rules at runtime (Rust guarantees); unsafe can
|
@fixingErrors |
  strategy1:return owned data (String/Value) instead of a reference to stack/param
  strategy2:take ownership of the param (drop the &) so the caller's value travels
  strategy3:clone the data and return the owned copy (costly, simple)
  strategy4:restructure lifetimes so returned ref outlives fn (tie to input lifetime)
  inspectSelf:error E0382 - value moved; E0381 - borrow of moved value
  diagnosticName:compiler names the moved variable and the move site (use its --explain)
  fixOrder:usually change the RETURN type or the & in the signature, then the body
  topBorrow:rustc suggests lifetimes; apply then check callsites
  safeProgram:no Fix needed - the & is fine, keep it
|
@slices |
  slice:&[T] or &str: borrow of a CONTIGUOUS sequence
  len:len computed at runtime, not compile time
  reference:slice references data owned elsewhere (String, Vec, array)
  borrowOf:&[T] borrows; String[0..len] gives &str
  bound:&s[..], let first = &s[0..4]; ("hello" -> "hell")
  underscores:elided bounds: [..] all, [..3] three from left, [2..] from right
  fixFirstWord:fn first_word(s: &String) -> &str (returns slice)
  fixFirstChar:fn first_char(&s[..]) -> &str, then wrap into vec<string>
  stringSlice:&str is how functions that take "a string" should be written
|
@structs |
  define:struct User { name: String, active: bool }
  instantiate:let u = User { name: String::from("x"), active: true }
  access:u.name, u.active
  mutation:let mut u = ...; u.name = String::from("y") (whole struct mut)
  shorthand:field init shorthand (same name as var)
  updateSyntax:..u2 within braces copies rest from u2 (moves non-Copy fields!)
  tupleStruct:struct Color(i32, i32, i32)
  unitStruct:struct AlwaysEqual; (no fields)
  tupleStructAccess:Color.0 or destructure let Color(r, g, b) = c;
  debugNormal:impl Debug trait (derive(Debug)) to use {:?} / {:#?} pretty print
  derive:derive(Debug, Clone, Copy) shorthand: #[derive(Debug)] before struct
  printPattern:println!("{:?}", x) won't work w/o Debug
  impl:impl Type { fn method(&self) { } }
  method:fn method(&self) { } (borrows self)
  mutMethod:fn method(&mut self) {} (mutates)
  self:consuming method  (takes ownership, releases)
  associatedFn:takes no self: Type::fn()  (e.g. String::from)
  lookup &&mut:both auto-included when looking up impl methods
|
@enums |
  define:enum IpAddr { V4(String), V6(String) }
  instantiate:let home = IpAddr::V4(String::from("127.0.0.1"))
  data:repr of variant carries data (like union but typed)
  rectangular:variants can differ in type + amount of data (like discriminated union)
  derive:derive(Debug) for enum
|
@match |
  arms:match value { pattern => result, _ => default }
  exhaustiveness:must cover all variants or _ arm
  patterns:() | (a, b) | { field: a } | enum value | _ wildcard
  binding:let x = match value { Some(i) => i, _ => 0 } (binding in arm)
  guard:match value { v if condition => ... } (arm guard predicate)
  enumMatch:match enum { Variant => ... } covers all variants
  refPattern:match &x { ref k => ... } or { ref mut k => ... } borrows (no move)
  ifLet:if let Some(x) = ... { } (single-arm convenience)
  whileLet:while let Some(k) = ... (loop while pattern matches)
  destructive:match may consume and deconstruct (moves out non-Copy fields)
  wildcard:_ catches everything remaining
|
@collections |
  vecA:let v = vec![1, 2, 3] / Vec::new()
  vecPush:let mut v = Vec::new(); v.push(1)
  vecIndex:v[0] (panic if out of bounds)
  vecGet:v.get(0) (Option<T>, no panic)
  vecMut:for x in &mut v { *x += 1 }
  vecLoop:for x in &v { } (borrow) / into_iter consumes
  vecLen:v.len()
  vecEmpty:v.is_empty()
  vecPop:v.pop() (Option<T>, removes last)
  vecCapacity:Vec::with_capacity(n), v.reserve(n), v.capacity()
  vecShrink:v.shrink_to_fit()
  vecRemove:v.remove(index)
  vecRetain:v.retain(|x| cond)
  vecContains:&v[i] == val (use v.contains(&val) — needs a ref because & vs move)
  vecContainsNeedRef:v.contains(&val) NOT v.contains(val) — passing ref
  vecEnumerate:for (i, x) in v.iter().enumerate()
  hashmapNew:use std::collections::HashMap; let mut m = HashMap::new()
  hashmapInsert:m.insert(key, value)
  hashmapGet:m.get(&key) (Option<&V>)
  hashmapGetMut:m.get_mut(&key) (Option<&mut V>)
  hashmapEntry:m.entry(key).or_insert(value) (avoids double-lookup)
  hashmapEntryEdit:m.entry(&word).and_modify(|w| *w += 1).or_insert(0);
  hashmapRemove:m.remove(&key)
  hashmapLen:m.len()
  hashmapIter:for (k, v) in &m { }
  stringVsStr:String owns; &str borrows; use str-slice in fn params
  mapOwnership:HashMap key must implement Hash + Eq (Copy or owned)
  hashmapUpdate:inserting value overwrites previous
  hashmapGetRef:m.get returns reference, needs unwrap_or or match
|
@errorHandling |
  panic:panic!("message") - unrecoverable; unwinds stack by default
  panicAbort:set panic='abort' in Cargo.toml [profile] to abort on panic
  unwind:default panic unwinds, dropping stack frames
  result:Result<T, E> = Ok(T) | Err(e)
  expect:my_result.expect("message") - panics if Err
  unwrap:my_result.unwrap() - panics if Err
  unwrapOr:my_result.unwrap_or(default)
  matchResult:match result { Ok(v) => v, Err(e) => panic!("{e}") }
  questionMark:let f = File::open("x")?; returns Err early (fn must return Result)
  questionFn:fn f() -> Result<T, E> { ... }? - early return Err
  questionType:? converts error types if From<E1> for E2; use Box<dyn Error> or map_err
  loadFromFile:let s = fs::read_to_string("f")?; (String)
  propagate:main() can return Result<(), Box<dyn Error>>
  choice:panic for programming bugs (index, unwrap of Invariant); Result for expected failure (files, io)
  recoverable:I/O and user input -> Result; unreachable bugs -> expect/panic
  catchUnwind:std::panic::catch_unwind(|| ...) (for FFI)
|
@generics |
  defFn:fn largest<T: PartialOrd + Copy>(list: &[T]) -> T
  syntax:fn name<T>(params) -> T { }
  traitBound:T: Trait or where T: Trait
  multipleBounds<T: Display + Clone, U: Debug>
  implGeneric:impl<T> Point<T> { fn x(&self) -> &T }
  genericStruct:struct Point<T> { x: T, y: T }
  genericDuplicate:T appears where you want the SAME type
  twoTypes:struct Pair<T, U> { a: T, b: U } (allow different)
  bounds:constraints on generic params (PartialOrd for comparison)
  monomorphization:generics resolved at compile time per concrete type (no runtime cost)
  typeInference:often inferred; be explicit when ambiguous
|
@traits |
  def:trait Summary { fn summarize(&self) -> String }
  implStruct:impl Summary for Article { fn summarize(&self) -> String }
  defaultImpl:fn summarize(&self) -> String { ... } default (override optional)
  bound:T: Summary
  where:fn notify<T>(item: &T) where T: Summary { }
  implTrait:fn returns impl Trait (any type implementing that trait)
  multipleTraits:impl Summary + Display
  traitObject:Box<dyn Summary> (erases type, runtime dispatch — known set)
  debugDerive:#[derive(Debug)] on struct types
  copyClone:Copy but NOT Clone (Clone explicit, Copy cheap implicit)
  ordering:impl Ord for comparisons (sorting, max)
  display:Display for user-facing output; Debug for {:?} debugging
  staticDispatch:generics/traits monomorphize -> static dispatch; dyn = runtime
|
@lifetimes |
  purpose:to express how long references live (borrow checker)
  lifecycle:lifetime of ref must be ≤ lifetime of borrowed value
  annotation:'a  |  fn name<'a>(x: &'a str) -> &'a str
  elision:borrow checker infers common patterns automatically (lifetime elision)
  elisionRules:1) each borrowed param gets its own 'a; 2) one input survives -> output gets same lifetime
  crossElided:two params elided -> outputs assume x (not y) unless annotations
  static:'static: whole-program lifetime (string literals: "..." as &'static str)
  borrowCheck:lifetimes resolved at COMPILE time (no runtime tags)
  shorterLifetime:borrow ends before variable dropped
  structLifetime:struct Foo<'a> { part: &'a str } (struct holds a ref)
  bestPractices:prefer owned data (String) over lifetime annotations when possible
  missingElision:errors show "lifetime may not live long enough" -> add annotation or restructure
|
@closures |
  def:|x| x + 1
  capture:closures can capture vars from enclosing scope (like Python lambdas)
  immutableCap:captures by reference and reads (may not mutate)
  movingStruct:moves captured variable (use move |x| ... if you own it)
  fnTraits:Fn (immutable borrow) | FnMut (mutable borrow) | FnOnce (consumes)
  inferFnTraits:complier auto-selects least restrictive that body uses
  moveForThread:pass move || ... to thread::spawn for owned-closure (static)
  sharing:closure can hold owned data (e.g. capture Vec<String>)
  ReturnClosure:fns can return closures (impl Fn)
|
@iterators |
  iterator:iterators are lazy (only compute at .next() call)
  next:let it = v.iter(); it.next() returns Option<&T>
  iter:&v Iter over references (read)
  iterMut:&mut v iter_mut for mutable refs
  intoIter:v.into_iter() consumes, gives owned items by value
  for:for x in &v { } works via iterator trait
  chain:iterator.chain(other) chains
  map:iterator.map(|x| x * 2).collect()
  filter:iterator.filter(|&x| x > 5).collect()
  flatMap:iterator.flat_map(|x| x.iter())
  all:iterator.all(|x| cond) (all match?) 
  find:iterator.find(|&x| cond) (first match, Option)
  fold:iterator.fold(0, |acc, x| acc + x)
  sum:iterator.sum()
  take:iterator.take(n)
  skip:iterator.skip(n)
  collect:iterator.collect::<Vec<_>>() or typed selection
  enumerate:enumerate() gives (index, item)
  zip:iterator.zip(other) pair up
  range:for i in 0..10 { } (exclusive top) / 0..=10 inclusive
  rev:iterator.rev()
  min/max:min() max() on iterator of Ord items
  count:count() counts items (consumer)
  lazySum:adding up runs automatically at collect
|
@concurrency |
  threads:std::thread::spawn(|| { ... })
  spawnClosure:thread::spawn(move || { }) - capture owned data (closure must be 'static)
  join:handle.join().unwrap() - waits for child
  moveReason:spawn requires closure 'static (any borrow dies before join -> move)
  errors:closure passed to spawn captures by ref -> compile error "requires 'static"
  raceCondition:data raced between threads (data protection needed)
  deadlock:threads waiting on each other (avoid multiple locks in different order)
  channels:std::sync::mpsc::channel(); tx.send(x); rx.recv() (blocks)
  channelBlocking:rx.recv() blocks until message; recv_timeout
  channelTry:rx.try_recv() non-blocking (immediately Option/Result)
  channelMultiple:multiple tx ends can send; one rx receives
  channelClosed:sending to closed rx returns Err (like file closed)
  sharedState:Mutex<T> wraps value; lock() -> guard (poisoned if thread panicked while holding)
  mutexLock:let mut data = mutex.lock().unwrap(); // auto-unlock at end of scope (RAII)
  sharedCounter:Arc<Mutex<T>> (atomically refcounted, clone to pass to each thread)
  arcClone:let counter = Arc::clone(&counter); inside loop/thread
  lockScope:guard drops at end of scope; don't wait while holding lock
|
@moduleSystem |
  package:crate (binary or library)
  module:mod module_name; fn inside pub mod
  filePerModule:put code in module_name.rs; mod module_name; in main.rs
  pub:pub fn - visible outside module; default private (like Python underscore but enforced)
  use:use crate::sub::module; simplifies paths
  useDeep:use std::collections::HashMap; (abbreviate long paths)
  super:super:: (parent module path) for nested module
  selfPath:self:: (current)
  globUse:use super::*; import everything
  privateByDefault:items private unless pub (unlike Python)
  externalDeps:declared in Cargo.toml [dependencies] section
  crateRoot:main.rs = binary crate root; lib.rs = library root
  prelude:std prelude auto-imported (basics only)
  pathResolution:absolute: crate::  relative: self:: super::
  shadows:same name from 2 mods -> use as alias (use std::fmt; use std::io;)
  reExport:pub use X (re-export to public API)
|
@tooling |
  rustc:rustc file.rs directly (no cargo needed for single file)
  cargoNew:cargo new name (creates Cargo.toml + src/main.rs, git init)
  cargoRun:cargo run
  cargoRunRelease:cargo run --release
  cargoTest:cargo test (unit tests in #[cfg(test)] mod tests)
  cargoTestName:cargo test name (filter)
  clippy:cargo clippy (lints)
  fmt:cargo fmt
  doc:cargo doc; cargo doc --open
  tree:cargo tree (dependencies)
  audit:cargo audit (vulnerabilities)
  deny:cargo deny (licenses, bans)
  add:cargo add <crate> (adds dependency to Cargo.toml)
  expand:cargo expand (see macro expansion, nightly-only by default)
  miri:cargo +nightly miri run (UB detection)
  bench:nightly-only unstable; use #[bench] or criterion
  profile:dev slightly slower compile vs release (opt level 0), good for iterations
  workspace:workspaces group multiple crates; members = ["./core"]
  edition:edition = "2021" (2024 released)
  target:rustup target add x86_64-unknown-linux-musl (cross)
  cross:cross build --target ...
  artifact:build produces binary at target/debug/<name> or target/release/<name>
  rustupComponents:rustup component add rust-src, clippy, rustfmt
|
@testing |
  unitTest:#[cfg(test)] mod tests { #[test] fn test_foo() { assert_eq!(a, b) } }
  assert:assert!(cond), assert_eq!(a, b)
  assertPoints:assert_eq! compares PartialEq; structs need derive(PartialEq)
  shouldPanic:#[should_panic] attribute
  shouldPanicExpect:#[should_panic(expected = "msg")] substring match
  ignore:#[ignore] slow tests
  resultTests:test fns can return Result<(), E> (then Err = fail)
  integrationTests:files in tests/ dir (crate public API only)
  cargoTestPkg:cargo test -- --nocapture (see prints)
  doctest:code in /// doc comments run as tests (for examples)
  bench:cargo bench (nightly) / criterion crate
|
@gotchas |
  borrowConflict:can't hold &mut + & at same time; restructure or clone
  moveConfused:math on String vs str-typed value -> unexpected move errors
  mutableBorrow:looping while mutating collection -> borrow checker rejects
  iteratingSelf:vec.push() while iterating &v
  mutableReadOnly:using &mut on readonly data -> compiler rejects
  returnRefToStack:returning &String from fn -> error "missing lifetime specifier"
  dropValueBeforeUse:value used after move/free (E0382)
  unionInit:enum variant construction has no default (must instantiate with V4(value))
  hashmapValueNeedsClone:HashMap::get returns &V - must clone to own
  borrowExhausted:iterating over &m then trying m.get_mut (double borrow)
  fixedClone:clone data to avoid mut-borrow conflicts (clone into own local)
  stackArrays:array out of bounds is a panic (runtime), not compile error
  overflow:2..100.. overflow debug-build panics
  selectEnum:switch on enum always need match all variants or _ wildcard
  matchRefs:match on owned data moves it; match on &x to borrow instead
  commonError:borrow checker error text long; focus on "cannot borrow X as mutable more than once"
  redBorrow:cannot borrow `v` as immutable because it is also borrowed as mutable (iterating + pushing)
  fixedRedBorrow:use Vec index loop instead of iterator, or clone
  everyPowPanics:integer overflow debug vs release (2^32 wraps in release)
  expectForBugs:panic for programming bugs = expect; recoverable = Result
|
@index |
  sections:core basics, types strings, ownership, borrowing, slices, structs enums match, collections, error handling, generics traits lifetimes, closures iterators, concurrency, modules tooling testing
  format:sectionName:@block1 @block2
  load:dots get rust.s @basics (top-level setup)
  quick:dots get rust.s @ownership (concept needed for Rust)
  quickRef:dots get rust.s @borrowing
  quickRef2:dots get rust.s @fixingErrors
  gotchas:dots get rust.s @gotchas
  beginners:dots get rust.s @basics @types @structs @ownership
|
@dependencies |
  requires:index.s
  related:javascript.s python.s
  browseSkills:javascript.s python.s
|