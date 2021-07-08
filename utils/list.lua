local debug = require("utils.debug");
local list = {}

function list.map(source, projection)
   local output = {};

   for i = 1, #source, 1 do
      local r = projection(source[i]);
      output[i] = r;
   end

   return output;
end

return list;
