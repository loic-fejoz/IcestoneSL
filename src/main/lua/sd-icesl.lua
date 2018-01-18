#!/usr/bin/env lua
-- https://www.shadertoy.com/view/4dtGWM
function emit(shape)
end

function implicit_distance_field(glsl)
    print(glsl)
end

function sdBox(...)
    local args = {...}
    return {kind="sdBox", args=args}
end

function sdTorus(r_outer, r_inner)
    return {kind="sdTorus", args={r_outer, r_inner}}
end

function sdUnion(...)
    local args = {...}
    return {kind="opUnion", children=args}
end

function sdBlend(...)
    local args = {...}
    return {kind="opBlend", children=args}
end

function sdTranslate(...)
    local args = {...}
    return {
        kind="opTranslate",
        args={args[1], args[2], args[3]},
        children={args[4]}
    }
end

function sdEmit(sdShape)
    defs = accumulateDefinition(sdShape, "")
    instances = accumulateInstances(sdShape, "", "p", "d")
    glsl = defs .. "\nfloat distance(vec3 p) {\n  float d;\n" .. instances .. "  return d;\n}\n"
    emit(implicit_distance_field(glsl))
end

function accumulateDefinition(sdShape, acc)
    if sdShape.kind == "sdBox" and sdShape.sdBox == nil then
        sdShape.sdBox = true
        acc = acc..[[
float sdBox(vec3 p, vec3 b)
{
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}
]]
    elseif sdShape.kind == "sdTorus" and sdShape.sdTorus == nil then
        sdTorus = true
        acc = acc..[[
float sdTorus(vec3 p, vec2 t)
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
]]
    else
        if sdShape.kind == "opBlend" and sdShape.opBlend == nil then
            sdShape.opBlend = true
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
        elseif sdShape.kind == "opUnion" and sdShape.opUnion == nil then
            sdShape.opUnion = true
            acc = acc .. [[
float opUnion( float d1, float d2 )
{
    return min(d1,d2);
}
]]
        end
        for k, v in pairs(sdShape.children) do
            acc = accumulateDefinition(v, acc)
        end
    end
    return acc
end

idCounter = 1
function accumulateInstances(sdShape, acc, p, d)
    if sdShape.kind == "opUnion" or sdShape.kind == "opBlend" then
        for k, v in pairs(sdShape.children) do
            acc = acc .. "  float d" .. k .. ";\n"
            acc = accumulateInstances(v, acc, "p", "d" .. k)
        end
        acc = acc .. "  " .. d .. " = " .. sdShape.kind .. "("
        for k, v in pairs(sdShape.children) do
            acc = acc .. "d" .. k
            if k ~= #sdShape.children then
                acc = acc .. ", "
            end
        end
        acc = acc .. ");\n"
    elseif sdShape.kind == "opTranslate" then
        theVar = "p" .. idCounter
        acc = acc .. "  vec3 " .. theVar .. " = p - vec3("
        idCounter = idCounter + 1
        acc = acc .. sdShape.args[1] .. ", " .. sdShape.args[2] .. ", " .. sdShape.args[3] .. ");\n"
        acc = accumulateInstances(sdShape.children[1], acc, theVar, d)
    else
        acc = acc .. "  " .. d .. " = " .. sdShape.kind .. "(" .. p .. ", vec" .. #sdShape.args
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

sdEmit(sdBlend(sdTorus(5, 3), sdTranslate(-3.5, 0, 0, sdBox(3, 4, 5))))
