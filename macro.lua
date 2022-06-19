--[[
program which reads files for C style macros and replaces text with the macro body
    Copyright (C) <2022>  <return5>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]



local function replaceWithMacros(macros,contents)
	for macro,func in pairs(macros) do
		contents = func(macro,contents)
	end
	return contents
end


local function makeParams(parameterList)
	local params <const> = {}
	for parameter in parameterList:gmatch("[^,]+,?") do
		local param <const> = parameter:match("[^,]+")
		params[#params + 1] = param
	end
	return params
end


--take a macro function in contents and replace it with the function body.
local function replaceFunction(params,func,funcName,contents,macro)
	--for each instance of the function macro.
	for funcMacro in contents:gmatch(macro) do
		--list of parameters in macro function
		local parameterValues <const> = makeParams(funcMacro:match("%(([^)]+)"))
		--the test which has been replaced with macro.
		local replacedContent = func
		local funcParamers = {funcName,"%("}
		for i=1,#params,1 do
			funcParamers[#funcParamers +1] = parameterValues[i]
			funcParamers[#funcParamers +1] = ","
			replacedContent = replacedContent:gsub(params[i],parameterValues[i])
		end
		funcParamers[#funcParamers] = nil
		funcParamers[#funcParamers + 1] = "%)"
		local macroToReplace <const> = table.concat(funcParamers)
		contents = contents:gsub(macroToReplace,replacedContent)
	end
	return contents
end

--function to take macros which match function form and parse it out.
local function makeMacroFunction(macros,defined)
	--grab the function name and the list of parameter for the macro function.
	local funcName <const>, parameterList <const>,func <const> = defined:match("#define%s+([^(]+)%(([^)]+)%)%s*([^\n\r]+)")
	--parse out the parameters into a table.
	local params <const> = makeParams(parameterList)
	--add macro function to the macros table.
	macros[funcName .. "%([^)]+%)"] = function(macro,content) return replaceFunction(params,func,funcName,content,macro) end
end

local function findMacros(contents)
	--table of macros which are defined in file.
	local macros <const> = {}
	--loop through contents and grab macro definitions of the form '#define MACRO BODY'
	for defined in contents:gmatch("#define%s*[^\n\r]+\n?\r?") do
		--if the macro matches the form of a function.
		if defined:match("#define%s+[^(]+%(([^)]+)%)") then
			makeMacroFunction(macros,defined)
		else
			local body <const> = defined:match("#define%s*[^%s]+%s*([^\n\r]+)")
			macros[defined:match("#define%s*([^%s]+)")] = function(macro,str) return str:gsub(macro,body) end
		end
	end
	--return table of macros and content of file sans the macro defintions.
	return macros,contents:gsub("#define%s*[^\n\r]+\n?\r?","")
end

local function scanFile(fileName)
	--open the file for reading.
	local readFile <const> = io.open(fileName,"r")
	--read contents of file into variable.
	local contents <const> = readFile:read("a*")
	--close file after reading.
	readFile:close()
	--parse through and grab the macros, and file content sans macro definitions.
	local macros <const>,updatedContents <const> = findMacros(contents)
	--search through contents and replace  macros.
	local replacedContents <const> = replaceWithMacros(macros,updatedContents)
	--open file to write content which has been replaced with macros
	local writeFile <const> = io.open(fileName,"w")
	--write content to file
	writeFile:write(replacedContents)
	--close file
	writeFile:close()
end


local function main()
	--for each file passed in.
	for i=1,#arg,1 do
		scanFile(arg[i])
	end
end


main()