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

function Point.__tostring(P) 
  return "("..P[1]..","..P[2]..","..P[3]..")" 
end 

function Point:translation(A,u)
  local B = Point:new(0,0,0)
  for i=1,3 do
    B[i]=A[i]+u[i]
  end
  return B
end


O = Point:new(0,0,0) 
I = Point:new(1,0,0) 
J = Point:new(0,1,0) 
K = Point:new(0,0,1) 

--définition de vecteur 

Vector = { } 

Vector.__index = Vector 

Vector.mt = {} 

function Vector:new(x,y,z) 
  local v = {x,y,z} 
  setmetatable(v,self.mt) 
  v.type = "vector"
  return v 
end 

Vector.zero = Vector:new(0,0,0)

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

function Vector:copy(v)
  local u = Vector:new(0,0,0)
  for i=1,3 do
    u[i]=v[i]
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
      table.insert(basis,Vector:normed(z)) 
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
  local n = #M
  for p in perm(n) do 
    local z = sign(p)
    for i=1,n do
      z = z*M[i][p[i]]
    end
    d = d + z 
  end 
  return d 
end 

function Vector:iscolinear(v1,v2)
  return (v1[1]*v2[2]==v2[1]*v1[2] and v1[1]*v2[3]==v2[1]*v1[3]) 
end
  
function Vector:iscoplanar(v1,v2,v3)
  return Vector:det({v1,v2,v3})==0
end


function invmat(M)
  local n = #M
  local c
  if n ~= 3 then
    error("In invmat, the argument is not a squared matrix")
  end
  local dep = {Vector:copy(M[1]),Vector:copy(M[2]),Vector:copy(M[3])}
  --print("dep");matprint(dep)
  local arr = {Vector:new(1,0,0),Vector:new(0,1,0),Vector:new(0,0,1)}
  for i=1,3 do
    if dep[i][i]==0 then
      k=i+1
      while dep[k][i]==0 do
        k=k+1
      end
      dep[i],dep[k] = dep[k],dep[i]
      arr[i],arr[k] = arr[k],arr[i]
    end
    c = dep[i][i]
    dep[i] = dep[i]/c
    --print("dep",dep[i])
    arr[i] = arr[i]/c
    --print("arr",arr[i])
    --matprint(dep)
    for j=1,3 do
      if j~=i then
        c = dep[j][i]
        dep[j] = dep[j]-c*dep[i]
        arr[j] = arr[j]-c*arr[i]
      end
    end
  end
  return arr
end
-- canonical base

e = {Vector:new(1,0,0),Vector:new(0,1,0),Vector:new(0,0,1)}

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
    print("Inverse of the base")
    matprint(invmat(bon))
    print("signature of 2,3,1 :",sign({2,3,1})) 
--    print("Generate perm with signature") 
--    for p in perm(3) do 
--      print("   "..permtostr(p).." sign="..sign(p)) 
--    end 
    print("det(v,z,e3)="..Vector:det{v,z,e3}) 
    print("det(e1,e2,e3)="..Vector:det{e1,e2,e3}) 
    
  end 





--Segments and line

Segment = {}

Line = {}

function Segment:new(A,B)
  local s = {A,B}
  setmetatable(s,self) 
  s.type = "segment"
  return s
end

function Line:new(...)
  local l = {}
  setmetatable(l,self)
  local args = {...}
  if #args > 2 then
    error("Line:new() : too many args")
  end
  local points = {}
  local vectors = {}
  for _,v in pairs(args) do
    if v.type == "point" then
      table.insert(points,v)
    elseif v.type== "vector" then
      table.insert(vectors,v)
    end
  end
  if #points == 2 then
    l.points = points
    l.vector = Vector:normed(Vector:vect(points[1],points[2]))
  else
    l.points = points
    l.vector = vectors[1]
  end
  l.type = "line"
  return l
end

function isinline(P,d)
  return Vector:iscolinear(Vector:new(P,d.points[1]),d.vector)
end


--Plane



Plane = {}

function Plane:new(...)
  local p = {}
  local args = {...}
  local points = {}
  local vectors = {}
  for _,v in pairs(args) do
    if v.type == "point" then
      table.insert(points,v)
    else
      table.insert(vectors,v)
    end
  end
  --print("nb args",#args,"nb points",#points,"nb vect",#vectors)
  if #points == 3 then
    p.points = points
    local u = Vector:normed(Vector:vect(points[1],points[2]))
    local v = Vector:normed(Vector:vect(points[1],points[3]))
    p.vectors = {u,v}
    p.normal = Vector:cross(u,v)
  elseif #vectors == 1 then
    p.points = points
    local bon = Vector:orthonormalize(vectors[1],e[1],e[2],e[3])
    p.normal = vectors[1]
    p.vectors = {bon[2],bon[3]}
  else
    p.points = points
    p.vectors = vectors
    p.normal = Vector:normed(Vector:cross(vectors[1],vectors[2]))
  end
  setmetatable(p,self)
  p.type = "plane"
  return p
end

function isinplane(Pt,pl)
  return Vector:dot(pl.normal,Vector:vect(Pt,pl.points[1]))==0
end

function intersection(obj1,obj2)
  local t1 = obj1.type
  local t2 = obj2.type
  if (t1=="line" and t2=="plane") or (t1=="plane" and t2=="line") then
    local d = (t1=="line" and obj1) or obj2
    local p = (t1=="plane" and obj1) or obj2
    if Vector:dot(d.vector,p.normal)==0 then
      print("plane and line parallels")
      if isinplane(d.points[1],p) then
        return d
      else
        return nil
      end
    else
      local t = (Vector:dot(p.points[1],p.normal)-Vector:dot(d.points[1],p.normal))/Vector:dot(p.normal,d.vector)
      return Point:new(d.points[1][1]+t*d.vector[1],d.points[1][2]+t*d.vector[2],d.points[1][3]+t*d.vector[3])
    end
  elseif t1=="plane" and t2=="plane" then
    local p1,p2 = obj1,obj2
    local v = Vector:normed(Vector:cross(p1.normal,p2.normal)) --vecteur directeur
    local mat = {Vector:normed(p1.normal),Vector:normed(p2.normal),v}
    local res = Vector:matmult(invmat(mat),Vector:new(Vector:dot(p1.points[1],p1.normal),Vector:dot(p2.points[1],p2.normal),0))
    local P = Point:new(res[1],res[2],res[3])
    local d = Line:new(P,v)
    return d
  elseif t1=="line" and t2=="line" then
    local d1,d2 = obj1,obj2
    if not(Vector:iscoplanar(d1.vector,d2.vector,Vector:vect(d1.points[1],d2.points[1]))) then
        return nil
    elseif Vector:iscolinear(d1.vector,d2.vector) then
      if isinline(d1.points[1],d2) then
        return d1
      else
        --intersection de deux droites secantes
      end
    end
    
  end
end

if test=="on" then
  p = Plane:new(Point:new(1,0,0),Point:new(0,1,0),Point:new(0,0,1) )
  d1 = Line:new(Point:new(1,1,1),Vector:new(0.5,1,1))
  A = intersection(p,d1)
  p2 = Plane:new(O,I,J)
  d2 = intersection(p,p2)
  print("intersection p et d",A)
  print("intersection p and p2 is a",d2.type)
  print("points in intersection")
  for k,v in pairs(d2.points) do
    print(k,v)
  end
  print("vector",d2.vector)
end


--Polygons

Polygon = {} 

function triangle(A,B,C) 
  local T = {A,B,C} 
  setmetatable(T,Polygon) 
  return T 
end 

function quad(A,B,C,D) 
  local T = {A,B,C,D} 
  setmetatable(T,Polygon) 
  return T 
end



-- Table of all created objects

Scene = {}

Scene.xmin = xmin or -5
Scene.xmax = xmax or  5
Scene.ymin = ymin or -5
Scene.ymax = ymax or  5
Scene.zmin = zmin or -5
Scene.zmax = zmax or  5 

Scene.viewpoint = Point:new(1,0.5,1)

kview = Vector:normed(Vector:vect(Scene.viewpoint,O))

local i=3
jview = Vector:new(0,0,0)

while jview == Vector.zero do
  jview = Vector:normed(e[i] - Vector:dot(e[i],kview)*kview)
  i = i-1
end

iview = Vector:cross(kview,jview)

Mrot = {iview,jview,kview}

print("matrix of rotation")
matprint(Mrot)

Scene.axis = {}

-- Table of drawn objects 

Predraw = {}



-- Table of polygons to draw effectively

Draw = {}

