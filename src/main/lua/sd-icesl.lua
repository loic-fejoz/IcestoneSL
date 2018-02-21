-- https://www.shadertoy.com/view/4dtGWM

distanceMethodName = "distance"

if emit == nil then
  function emit(shape)
  end
end

if implicit_distance_field == nil then
  if implicit == nil then
    function implicit_distance_field(pmin, pmax, glsl)
      print(glsl)
    end
  else
    distanceMethodName = "distanceEstimator"
    function implicit_distance_field(pmin, pmax, glsl)
      --print(glsl)
      return implicit(pmin, pmax, glsl)
    end
  end
end

function sdBox(...)
    local args = {...}
    return {kind="sdBox", args=args}
end

function sdTorus(r_outer, r_inner)
    return {kind="sdTorus", args={r_outer, r_inner}}
end

function sdSphere(radius)--
    return {kind="sdSphere", args={radius}}
end

function sdUnion(...)
    local args = {...}
    if args[1] == nil then
      return args[2]
    end
    return {kind="opUnion", children=args}
end

function sdBlend(...)
    local args = {...}
    if args[1] == nil then
      --print("skipping sdBlend first arg")
      return args[2]
    end
    if args[2] == nil then
      --print("skipping sdBlend second arg")
      return args[1]
    end
    return {kind="opBlend", children=args}
end

Modifier = {}

function Modifier.__mul(modifier, shape)
  modifier.children = { shape }
  return modifier
end

function sdTranslate(...)
    local args = {...}
    -- TODO test of #args == 1 and if it is a vector
    --print("sdTranslate(" .. args[1] .. ", " .. args[2] .. ", " ..args[3] .. ")")
    local modifier = {
        kind="opTranslate",
        args={args[1], args[2], args[3]}
    }
    setmetatable(modifier, Modifier)
    return modifier
end

function sdImplicit(pmin, pmax, sdShape)
  if sdShape == nil then
    return nil
  end
  local defs = accumulateDefinition(sdShape, "")
  local instances = accumulateInstances(sdShape, "", "p", "d")
  local glsl = defs .. "\nfloat " .. distanceMethodName .. "(vec3 p) {\n  float d;\n" .. instances .. "  return d;\n}\n"
  --print(glsl)
  return implicit_distance_field(
    pmin,
    pmax,
    glsl)
end

function sdEmit(sdShape)
    local obj = sdImplicit(
      v(-20, -20, -20),
      v(20, 20, 20),
      sdShape)
    emit(obj)
end

decl = {}

function accumulateDefinition(sdShape, acc)
    if sdShape.kind == nil then
      print("buggy sdShape")
      return acc
    end
    if sdShape.kind == "sdBox" then
      if decl.sdBox == nil then
        decl.sdBox = true
        acc = acc..[[
float sdBox(vec3 p, vec3 b)
{
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}
]]
      end
    elseif sdShape.kind == "sdTorus" then
      if decl.sdTorus == nil then
        decl.sdTorus = true
        acc = acc..[[
float sdTorus(vec3 p, vec2 t)
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
]]
      end
    elseif sdShape.kind == "sdSphere" then
      if decl.sdSphere == nil then
        decl.sdSphere = true
        acc = acc..[[
float sdSphere(vec3 p, float s)
{
  return length(p)-s;
}
]]
      end
    else
        if sdShape.kind == "opBlend" and decl.opBlend == nil then
            decl.opBlend = true
            acc = acc .. [[
float polysmin(float a, float b, float k)
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float opBlend(float d1, float d2)
{
    return polysmin(d1, d2, 0.5);
}
]]
        elseif sdShape.kind == "opUnion" and decl.opUnion == nil then
            decl.opUnion = true
            acc = acc .. [[
float opUnion( float d1, float d2 )
{
    return min(d1,d2);
}
]]
        end

        if sdShape.children == nil then
          print(sdShape.kind .. " has no child")
          return acc
        end
        for k, v in pairs(sdShape.children) do
            acc = accumulateDefinition(v, acc)
        end
    end
    return acc
end

idCounter = 1
function accumulateInstances(sdShape, acc, p, d)
  if sdShape.kind == nil then
    print("buggy sdShape")
    return acc
  end
    if sdShape.kind == "opUnion" or sdShape.kind == "opBlend" then
        for k, v in pairs(sdShape.children) do
            local theVar = "d" .. idCounter
            v.var = theVar
            idCounter = idCounter + 1
            acc = acc .. "  float " .. theVar .. ";\n"
            acc = accumulateInstances(v, acc, "p", theVar)
        end
        acc = acc .. "  " .. d .. " = " .. sdShape.kind .. "("
        for k, v in pairs(sdShape.children) do
            acc = acc .. v.var --"d" .. k
            if k ~= #sdShape.children then
                acc = acc .. ", "
            end
        end
        acc = acc .. ");\n"
    elseif sdShape.kind == "opTranslate" then
        local theVar = "p" .. idCounter
        acc = acc .. "  vec3 " .. theVar .. " = p - vec3("
        idCounter = idCounter + 1
        acc = acc .. sdShape.args[1] .. ", " .. sdShape.args[2] .. ", " .. sdShape.args[3] .. ");\n"
        acc = accumulateInstances(sdShape.children[1], acc, theVar, d)
    else
      assert(sdShape.kind ~= nil)
        acc = acc .. "  " .. d .. " = " .. sdShape.kind .. "(" .. p .. ", "
        if #sdShape.args ~= 1 then
          acc = acc .. "vec" .. #sdShape.args
        end
        acc = acc .. "("
        for k, v in pairs(sdShape.args) do
            acc = acc .. v
            if k ~= #sdShape.args then
                acc = acc .. ", "
            end
        end
        acc = acc .. "));\n"
    end
    return acc
end
