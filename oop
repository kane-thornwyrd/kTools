-- Create a new class that inherits from a base class
--
function inheritsFrom( baseClass, baseProperties )
    local new_class = {}
    local class_mt = { __index = new_class }

    if type(baseProperties) == 'table' then
      for k, v in pairs(baseProperties) do
        if k == 1 then return
        else
          new_class[k] = v
        end
      end
    end

    function new_class:create( params )
        local newinst = {}
        if type(params) == 'table' then
          for k, v in pairs(params) do
            newinst[k] = v
          end
        end

        setmetatable( newinst, class_mt )
        return newinst
    end

    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:superClass()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return new_class
end
