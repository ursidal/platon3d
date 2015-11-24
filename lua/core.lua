--debugging functions 
test = "on" 

function tprint(t) 
  local txt = "{" 
  local sep = "" 
  for k,v in pairs(t) do 
    txt = txt..sep.. k ..":"..tostring(v) 
    sep = ", " 
  end 
  txt = txt .. "}" 
  print(txt) 
end 

function matprint(m) 
  local txt = "[" 
  local sep = "" 
  local chline = "" 
  for i,v in ipairs(m) do 
    if type(v) == "table" then 
      txt = txt..chline.."[" 
      sep = "" 
      chline = "\n " 
      for j,w in ipairs(v) do 
        txt = txt..sep..w 
        sep = "," 
      end 
      txt = txt .."]" 
    else 
      txt = txt..sep..v 
    end 
  end 
  print(txt.."]") 
end 

--définition de point 

Point = {} 

function Point:new(x,y,z) 
  local A = {x,y,z} 
  setmetatable(A,self)
  A.type = "point"
  return A 
end 

O = Point:new(0,0,0) 
I = Point:new(1,0,0) 
J = Point:new(0,1,0) 
K = Point:new(0,0,1) 

--définition de vecteur 

u = {x = 1, y = 0, z = 0} 

Vector = { 
  zero={0,0,0} 
  } 

Vector.__index = Vector 

Vector.mt = {} 

setmetatable(Vector.zero,Vector.mt) 
Vector.zero.type="vector"

function Vector:new(x,y,z) 
  local v = {x,y,z} 
  setmetatable(v,self.mt) 
  v.type = "vector"
  return v 
end 

function Vector.mt.__add(a,b) 
  local res = Vector:new(0,0,0) 
  for i=1,3 do 
    res[i]=a[i]+b[i] 
  end 
  return res 
end 

function Vector.mt.__unm(a) 
  local res = Vector:new(0,0,0)
  for i=1,3 do 
    res[i]=-a[i] 
  end 
  return res 
end 

function Vector.mt.__sub(a,b) 
  local res = Vector:new(0,0,0)
  for i=1,3 do 
    res[i]=a[i]-b[i] 
  end 
  return res 
end 

function Vector.mt.__mul(a,b) 
  local res = Vector:new(0,0,0) 
  if type(a)=="number" then 
    for i=1,3 do 
      res[i] = a* b[i] 
    end 
  else 
    for i=1,3 do 
      res[i] = b* a[i] 
    end 
  end 
  return res 
end 

function Vector.mt.__div(a,b) 
  local res = Vector:new(0,0,0)
    for i=1,3 do 
      res[i] = a[i]/b 
    end 
  return res 
end 

function Vector.mt.__len(a) 
  return math.sqrt(Vector:dot(a,a)) 
end 

function Vector.mt.__tostring(v) 
  return "("..v[1]..","..v[2]..","..v[3]..")" 
end 

function Vector.mt.__eq(u,v) 
  local ans = true 
  for i=1,3 do 
    ans = ans and u[i]==v[i] 
  end 
  return ans 
end 



function Vector:vect(A,B) 
  local u=Vector:new(0,0,0)
  for i=1,3 do 
    u[i]=B[i]-A[i] 
  end 
  return u 
end 

function Vector:dot(a,b) 
   local n = (a[1]*b[1]+a[2]*b[2]+a[3]*b[3]) 
  return n 
end 

function Vector:cross(a,b) 
  local c = Vector:new(0,0,0)
  for i=1,3 do 
    i1 = (i)%3 + 1 
    i2 = (i+1)%3 + 1 
    c[i]=a[i1]*b[i2]-a[i2]*b[i1] 
  end 
  return c 
end 

function Vector:normed(a) 
  local n = math.sqrt(Vector:dot(a,a)) 
  local res = a /n 
  return res 
end 

function Vector:orthonormalize(...) 
  local basis = {} 
  for i,v in ipairs{...} do 
    z = Vector:normed(v) 
    for _,u in ipairs(basis) do 
      z = z - Vector:dot(z,u)*u 
    end 
    if z~= Vector.zero then 
      table.insert(basis,z) 
    end 
  end 
  return basis 
end 

function Vector:matmult(M,v) -- M is a table of vectors 
  local res = {} 
  for i,u in ipairs(M) do 
    res[i] = Vector:dot(u,v) 
  end 
  setmetatable(res,self.mt) -- M must be squared matrix to be consistent 
  return res 
end 

function Vector:transp(m) -- transposition 
  local res = {} 
  if type(m[1]) == "table" then 
    for i,_ in ipairs(m[1]) do 
      res[i]={} 
      setmetatable(res[i],self.mt) 
    end 
  else 
    for i,_ in ipairs(m) do 
      res[i]={} 
      setmetatable(res[i],self.mt) 
    end 
  end 
  for i,v in ipairs(m) do 
    for j,w in ipairs(v) do 
      res[j][i]=w 
    end 
  end 
  return res 
end 

-- generator of permutation from PIL 
function permgen (a, n) 
  if n == 0 then 
    coroutine.yield(a) 
  else 
    for i=1,n do 

      -- put i-th element as the last one 
      a[n], a[i] = a[i], a[n] 

      -- generate all permutations of the other elements 
      permgen(a, n - 1) 

      -- restore i-th element 
      a[n], a[i] = a[i], a[n] 

    end 
  end 
end 

function perm (n) 
  local a = {} 
  for i=1,n do 
    a[i]=i 
  end 
  local co = coroutine.create(function () permgen(a, n) end) 
  return function ()   -- iterator 
    local code, res = coroutine.resume(co) 
    return res 
  end 
end 

function permtostr(p) 
  local txt = "(" 
  local sep = "" 
  for i=1,#p do 
    txt = txt..sep..p[i] 
    sep = "," 
  end 
  return txt..")" 
end 

function sign(perm) 
  local e = 1 
  for i=1,#perm do 
    for j= (i+1),#perm do 
      if perm[i]>perm[j] then 
        e = -e 
      end 
    end 
  end 
  return e 
end 

function Vector:det(M) 
  local d = 0 
  for p in perm(3) do 
    d = d + sign(p)*M[1][p[1]]*M[2][p[2]]*M[3][p[3]] 
  end 
  return d 
end 

  if test == "on" then 
    v= Vector:vect(I,J) 
    e1 = Vector:vect(O,I) 
    e2 = Vector:vect(O,J) 
    e3 = Vector:vect(O,K) 
    print("v:",v) --(-1,1,0) 

    z = Vector:new(1,2,3) 
    print("z:",z) --(1,2,3) 
    print("normed z:",Vector:normed(z)) --(0.26726124191242,0.53452248382485,0.80178372573727) 

    u = v+z 
    print("u=v+z :",u) 
    print("-u:",-u) 
    print("||u||:",#u) 
    print("v-z:",v-z) 
    print("Is v equal z ?", v==z) 
    print("Is v equal e2-e1 ?",v==e2-e1) 
    print("v.z="..Vector:dot(v,z)) 
    print("v x z:",Vector:cross(v,z)) 
    print("(1,0,0)x(0,1,0)=",Vector:cross({1,0,0},{0,1,0})) 
    print("(0,1,0)x(1,0,0)=",Vector:cross({0,1,0},{1,0,0})) 
    bon = Vector:orthonormalize(z,v,e3) 
    print("Orthonormal base from z,v,e3:") 
    matprint(bon) 
    print("Transpose of the previous base") 
    matprint(Vector:transp(bon)) 
    print(sign({2,3,1})) 
    print("Generate perm with signature") 
    for p in perm(3) do 
      print("   "..permtostr(p).." sign="..sign(p)) 
    end 
    print("det(v,z,e3)="..Vector:det{v,z,e3}) 
    print("det(e1,e2,e3)="..Vector:det{e1,e2,e3}) 
  end 

--définition d'un polygone 

polygon = {} 

function triangle(A,B,C) 
  local T = {A,B,C} 
  setmetatable(T,polygon) 
  return T 
end 

function quad(A,B,C,D) 
  local T = {A,B,C,D} 
  setmetatable(T,polygon) 
  return T 
end
