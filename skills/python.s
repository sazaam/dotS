# Python 3 Knowledge Base

@meta |topic:python3|version:3.12+|lastUpdated:2026-08-17|confidence:high|

@basics |
  version:3.12+
  interpreter:python3
  packageManager:pip, pipx, poetry, uv
  configFile:pyproject.toml, setup.py, setup.cfg
  lockFile:requirements.txt, poetry.lock, uv.lock
  virtualEnv:python3 -m venv .venv
  activate:source .venv/bin/activate
  deactivate:deactivate
|

@types |
  none:None
  bool:bool (True, False)
  int:int (unlimited precision)
  float:float (64-bit double)
  str:str (immutable, UTF-8)
  bytes:bytes (immutable, raw)
  list:list (mutable sequence)
  tuple:tuple (immutable sequence)
  dict:dict (key-value mapping)
  set:set (unique, unordered)
  frozenset:frozenset (immutable set)
  complex:complex (real, imag)
|

@strings |
  create:"hello" or 'hello' or """multi"""
  fstring:f"Hello, {name}!"
  fexpr:f"{2 + 2}"
  fformat:f"{value:.2f}"
  falign:f"{value:>10}"
  methods:split, join, strip, replace, find, count
  upper:s.upper()
  lower:s.lower()
  title:s.title()
  capitalize:s.capitalize()
  startswith:s.startswith("he")
  endswith:s.endswith("lo")
  replace:s.replace("old", "new")
  strip:s.strip()  # remove whitespace
  lstrip:s.lstrip()
  rstrip:s.rstrip()
  split:s.split(", ")
  join:", ".join(list)
  find:s.find("ell")  # -1 if not found
  count:s.count("l")
  encode:s.encode("utf-8")
  decode:b.decode("utf-8")
  format:"{} {}".format(a, b)
  raw:r"hello\nworld"
  multiline:'''line1\nline2'''
  slice:s[1:3]
  reverse:s[::-1]
  repeat:s * 3
  in:"ell" in "hello"
  len:len(s)
|

@lists |
  create:lst = [1, 2, 3]
  access:lst[0]
  slice:lst[1:3]
  append:lst.append(4)
  insert:lst.insert(0, "a")
  extend:lst.extend([4, 5])
  remove:lst.remove(3)
  pop:lst.pop()
  popIndex:lst.pop(0)
  del:del lst[1]
  clear:lst.clear()
  sort:lst.sort()
  sortKey:lst.sort(key=lambda x: x["name"])
  reverse:lst.reverse()
  copy:lst.copy()
  count:lst.count(3)
  index:lst.index(3)
  in:3 in lst
  enumerate:for i, v in enumerate(lst)
  zip:for a, b in zip(list1, list2)
  comprehension:[x * 2 for x in range(10)]
  filter:[x for x in lst if x > 5]
  nested:[[0 for _ in range(3)] for _ in range(3)]
  unpack:first, *rest = lst
  sliceAssign:lst[1:3] = [4, 5]
|

@tuples |
  create:t = (1, 2, 3)
  single: t = (1,)  # trailing comma required
  access:t[0]
  unpack:a, b, c = t
  unpackStar:first, *rest = t
  len:len(t)
  count:t.count(1)
  index:t.index(2)
  in:1 in t
  named:from collections import namedtuple
  namedCreate:Point = namedtuple("Point", ["x", "y"])
  namedAccess:p.x, p.y
|

@dicts |
  create:d = {"key": "value"}
  access:d["key"]
  accessDefault:d.get("key", "default")
  set:d["key"] = "value"
  update:d.update({"key2": "value2"})
  setdefault:d.setdefault("key", "default")
  pop:d.pop("key")
  popDefault:d.pop("key", None)
  del:del d["key"]
  clear:d.clear()
  keys:d.keys()
  values:d.values()
  items:d.items()
  in:"key" in d
  copy:d.copy()
  fromkeys:dict.fromkeys(keys, "default")
  merge:{**d1, **d2}
  merge39+:d1 | d2 (Python 3.9+)
  comprehension:{k: v for k, v in items}
  filter:{k: v for k, v in d.items() if v > 0}
  nested:d = {"a": {"b": {"c": 1}}}
  accessNested:d["a"]["b"]["c"]
  accessNestedSafe:d.get("a", {}).get("b", {}).get("c")
|

@sets |
  create:s = {1, 2, 3}
  empty:s = set()  # not {} (that's a dict)
  add:s.add(4)
  remove:s.remove(3)  # raises KeyError
  discard:s.discard(3)  # no error
  pop:s.pop()
  clear:s.clear()
  union:s1 | s2
  intersection:s1 & s2
  difference:s1 - s2
  symmetricDifference:s1 ^ s2
  isSubset:s1 <= s2
  isSuperset:s1 >= s2
  comprehension:{x for x in range(10)}
  frozen:frozenset([1, 2, 3])
|

@controlFlow |
  if:if condition: ...
  elif:elif condition: ...
  else:else: ...
  ternary:x = a if condition else b
  forLoop:for i in range(10): ...
  forElse:for...else (else runs if no break)
  whileLoop:while condition: ...
  whileElse:while...else
  break:break
  continue:continue
  pass:pass
  match:match value: case pattern: ... (3.10+)
|

@functions |
  def:def func(a, b=10): ...
  return:return value
  multipleReturn:return a, b  # returns tuple
  unpackReturn:a, b = func()
  args:def func(*args): ...
  kwargs:def func(**kwargs): ...
  keywordOnly:def func(*, key=val): ...
  positionalOnly:def func(pos, /, key=val): ...
  lambda:lambda x, y: x + y
  annotation:def func(a: int, b: str = "hello") -> bool: ...
  closure:def outer(): def inner(): ...
  decorator:@decorator def func(): ...
  decoratorWithArgs:@decorator(arg) def func(): ...
  property:@property def name(self): return self._name
  staticMethod:@staticmethod def func(): ...
  classMethod:@classmethod def from_string(cls, s): ...
  generator:def gen(): yield value
  async:async def func(): await ...
  docstring:def func(): """Description"""
|

@classBasics |
  class:class Person: ...
  init:def __init__(self, name): ...
  self:self refers to instance
  classVar:class_var = value (shared)
  instanceVar:self.name = name (per-instance)
  method:def method(self): ...
  str:def __str__(self): return "string"
  repr:def __repr__(self): return "repr"
  eq:def __eq__(self, other): return self.x == other.x
  lt:def __lt__(self, other): return self.x < other.x
  hash:def __hash__(self): return hash(self.x)
  context:def __enter__(self): ... def __exit__(self, ...): ...
  iterator:def __iter__(self): ... def __next__(self): ...
  inherit:class Child(Parent): ...
  super:super().__init__()
  mro:Child.__mro__
|

@contextManagers |
  with:with open("f") as fp: ...
  custom:from contextlib import contextmanager
  contextManager:@contextmanager def cm(): yield value
  asyncCM:async with aiofile() as f: ...
  suppress:with contextlib.suppress(FileNotFoundError): ...
  exitStack:with ExitStack() as s: ...
|

@exceptions |
  try:try: ... except Error as e: ...
  finally:try: ... finally: ...
  raise:raise ValueError("msg")
  reraise:raise
  custom:class MyError(Exception): ...
  withCause:raise Error("msg") from original
  exceptMultiple:except (TypeError, ValueError) as e: ...
  exceptAll:except Exception as e: ...
  assert:assert condition, "message"
  assertDisabled:python -O script.py
|

@comprehensions |
  list:[x * 2 for x in range(10)]
  listFilter:[x for x in range(10) if x % 2 == 0]
  dict:{k: v for k, v in items if v}
  set:{x for x in range(10)}
  gen:(x * 2 for x in range(10))
  nested:[y for x in matrix for y in x]
  walrus:[y for x in range(10) if (y := x * 2) > 5]
|

@walrus |
  assignment:= in expressions
  if:if (n := len(data)) > 10: print(n)
  while:while chunk := f.read(8192): process(chunk)
  comprehension:[y for x in data if (y := process(x))]
|

@decorators |
  simple:def decorator(func): def wrapper(*a, **k): return func(*a, **k); return wrapper
  args:def decorator(arg): return lambda func: wrapper(func, arg)
  classDec:from functools import wraps
  wraps:@wraps(func) def wrapper(): ...
  lru:@lru_cache(maxsize=128)
  cache:@cache (Python 3.9+)
  property:@property def name(self): return self._name
  setter:name.setter def name(self, val): self._name = val
|

@iterators |
  iterable:for x in collection: ...
  iterator:iter = iter(collection); next(iter)
  generator:def gen(): yield value
  yieldFrom:yield from generator
  genExpr:(x * 2 for x in range(10))
  stopIteration:raised by next() when exhausted
  enumerate:for i, v in enumerate(lst): ...
  zip:for a, b in zip(lst1, lst2): ...
  map:for v in map(func, lst): ...
  filter:for v in filter(func, lst): ...
  chain:from itertools import chain; chain(iter1, iter2)
  islice:from itertools import islice; islice(iter, 5)
|

@async |
  async:async def func(): ...
  await:await coroutine()
  gather:asyncio.gather(c1, c2)
  createTask:asyncio.create_task(coro())
  sleep:await asyncio.sleep(1)
  wait:asyncio.wait(tasks)
  asCompleted:for c in asyncio.as_completed(tasks): ...
  toThread:await asyncio.to_thread(sync_func)
  eventLoop:asyncio.run(main())
  queue:asyncio.Queue()
  lock:asyncio.Lock()
  event:asyncio.Event()
  semaphore:asyncio.Semaphore(10)
|

@fileIO |
  read:with open("f") as f: data = f.read()
  readline:line = f.readline()
  readlines:lines = f.readlines()
  write:with open("f", "w") as f: f.write("text")
  append:with open("f", "a") as f: f.write("text")
  binary:open("f", "rb") or open("f", "wb")
  encoding:open("f", encoding="utf-8")
  pathlib:from pathlib import Path
  pathlibRead:Path("f").read_text()
  pathlibWrite:Path("f").write_text("text")
  pathlibExists:Path("f").exists()
  pathlibMkdir:Path("dir").mkdir(parents=True, exist_ok=True)
  glob:list(Path(".").glob("*.py"))
  rglob:list(Path(".").rglob("*.py"))
|

@dataClasses |
  import:from dataclasses import dataclass
  basic:@dataclass class Point: x: float; y: float
  defaults:@dataclass class Config: name: str = "default"
  frozen:@dataclass(frozen=True) class Immutable: ...
  field:from dataclasses import field
  fieldDefault:field(default_factory=list)
  asDict:from dataclasses import asdict
  asDictUse:asdict(instance)
  astuple:from dataclasses import astuple
  astupleUse:astuple(instance)
|

@typing |
  basic:str, int, float, bool, None
  optional:Optional[str] or str | None
  union:Union[str, int] or str | int
  list:list[int]
  dict:dict[str, int]
  tuple:tuple[int, str]
  set:set[int]
  any:Any
  callable:Callable[[int, str], bool]
  type:Type[MyClass]
  literal:Literal["a", "b", "c"]
  typeVar:T = TypeVar("T")
  protocol:Protocol (structural typing)
  typedDict:TypedDict("Name", key=str)
  final:Final[int] = 5
  typeAlias:TypeAlias = dict[str, list[int]]
  cast:cast(int, value)
  assertIsInstance:assert isinstance(x, int)
|

@gotchas |
  mutDefault:def func(lst=[]): lst.append(1); return lst
  mutDefaultFix:def func(lst=None): lst = lst or []
  mutableDefault:class C: lst = []  # shared across instances!
  mutableDefaultFix:def __init__(self): self.lst = []
  floatCompare:0.1 + 0.2 != 0.3
  floatFix:abs(a - b) < 1e-9
  scopePython:for i in range(10): pass; print(i)  # i leaks!
  scopeFix:use _ prefix for throwaway vars
  importSideEffect:import runs module code
  circularImport:from a import b; from b import a
  circularFix:import inside function
  encoding:always specify encoding="utf-8"
  bytesVsStr:bytes != str
  bytesFix:decode() to str, encode() to bytes
  gil:threading doesn't parallelize CPU tasks
  gilFix:use multiprocessing for CPU-bound
  asyncGIL:async is I/O only, not CPU parallel
  matchCase:match is not switch (3.10+)
  walrus:= is assignment expression (3.8+)
|

@testing |
  pytest:pytest test_file.py
  pytestMarker:@pytest.mark.parametrize
  pytestFixture:@pytest.fixture
  pytestMonkeypatch:monkeypatch.setattr
  pytestRaise:with pytest.raises(Error): ...
  unittest:class Test(unittest.TestCase): ...
  unittestMethod:def test_something(self): ...
  mock:from unittest.mock import patch, MagicMock
  mockPatch:@patch("module.function")
  coverage:pytest --cov=src
  coverageReport:pytest --cov=src --cov-report=html
|

@tooling |
  ruff:ruff check .
  ruffFix:ruff check --fix .
  black:black .
  isort:isort .
  mypy:mypy src/
  pyright:pyright src/
  typeCheck:mypy or pyright
  format:black . || ruff format .
  lint:ruff check .
  lintFix:ruff check --fix .
  venv:python3 -m venv .venv
  pip:pip install -r requirements.txt
  poetry:poetry install
  uv:uv sync
|
