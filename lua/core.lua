
--définition de point

Point = {}

function Point:new(x,y,z)
  local A = {x,y,z}
  setmetatable(A,self)
  return A
end

O = Point:new(0,0,0)
I = Point:new(1,0,0)
J = Point:new(0,1,0)
K = Point:new(0,0,1)

--définition de vecteur

u = {x = 1, y = 0, z = 0}




  
Vector = {}

Vector.__index = Vector

Vector.mt = {}

function Vector.mt.__add(a,b)
  local res = {}
  setmetatable(res,Vector.mt)
  for i=1,3 do
    res[i]=a[i]+b[i]
  end
  return res
end

function Vector.mt.__unm(a)
  local res = {}
  setmetatable(res,Vector.mt)
  for i=1,3 do
    res[i]=-a[i]
  end
  return res
end

function Vector.mt.__sub(a,b)
  local res = {}
  setmetatable(res,Vector.mt)
  for i=1,3 do
    res[i]=a[i]-b[i]
  end
  return res
end

function Vector.mt.__mul(a,b)
  local res = {}
  setmetatable(res,Vector.mt)
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
  local res = {}
  setmetatable(res,Vector.mt)
  
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


function Vector:new(x,y,z)
  local v = {x,y,z}
  setmetatable(v,self.mt)
  return v
end



function Vector:vect(A,B)
  local u={}
  setmetatable(u,self.mt)
  for i=1,3 do
    u[i]=B[i]-A[i]
  end
  return u
end

function Vector:dot(a,b)
   local n = (a[1]*b[1]+a[2]*b[2]+a[3]*b[3])
  return n
end


function Vector:normed(a)
  local n = math.sqrt(Vector:dot(a,a))
  local res = a /n
  setmetatable(res,self.mt)
  return res
end

 



v= Vector:vect(I,J)

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

print(v) --(-1,1,0)

z = Vector:new(1,2,3) 
print(z) --(1,2,3)
print(Vector:normed(z)) --(0.26726124191242,0.53452248382485,0.80178372573727)

u = v+z
print(u)
print(-u)
print(#u)
print(v-z)
print(Vector:dot(v,z))
