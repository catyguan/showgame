-- ascension/Mod.lua
local Class = class.define("ascension.Mod", {"bma.lang.StdObject", "ascension.Const"})
local CSET = class.forName("ascension.CardSet")

local LDEBUG = LOG:debugEnabled()
local LTAG = "Ascension"

function Class:ctor(data)
	self:prop("HP", V(data.HP, 1))
	self:prop("MAXHP", V(data.MAXHP, 1))
	self:prop("handmax", V(data.handmax, 3))
end

function Class:ToString()
	return self:prop("who").."[Mod]"
end

function Class:addMaxHP(v, dg)
	self:changeProp("MAXHP", v, dg)
	self:changeProp("HP", v, dg)
end

function Class:setProp(n, v, dg)
	if n=="HP" then
		local v0 = V(self:prop("MAXHP"),0)
		if v0~=0 then
			if v>v0 then v = v0 end
		end
	end
	if v<0 then v = 0 end
	self:prop(n, v)
	if dg then
		self:prop("sid", dg:prop("sid"))
	end
	return v
end

function Class:changeProp(n, v, dg)
	local ov = self:prop(n)
	local nv = v
	if ov~=nil then
		nv = ov + v
	end
	if nv<0 then nv = 0 end
	if ov~=nv then
		return self:setProp(n, nv, dg)
	end
	return ov
end

function Class:hasEffect(id)
	local effs = self:prop("effects")
	if effs then
		for i, old in ipairs(effs) do
			local oid = old:prop("id")
			if oid and old:prop("id") == id then
				return true
			end
		end
	end
	return false
end

function Class:applyEffect(eff)
	local effs = self:prop("effects")
	if not effs then
		effs = {}
		self:prop("effects", effs)
	end
	if eff:prop("unique") then
		for i, old in ipairs(effs) do
			local oid = old:prop("id")
			if oid and oid == eff:prop("id") then
				eff:onRemove(self)
				table.remove(effs, i)
				break
			end
		end
	end
	table.insert(effs, eff)
	eff:apply(self)
end

function Class:applyFlag(n)
	local v = self:prop(n)
	if v==nil then
		v = 1
	else
		v = v + 1
	end
	self:prop(n, v)
end

function Class:removeFlag(n)
	local v = self:prop(n)
	if v~=nil then
		v = v - 1
		if v<=0 then
			self:removeProp(n)
		else
			self:prop(n, v)
		end
	end
end

function Class:getSet(idx)
	local sets = self:prop("sets")
	if sets then
		return sets[idx]
	end
	return nil
end
------------------------
function Class:doDrawHand(cbd)
	local hand = self:getSet(Class.SET_HAND)
	local hmax = self:prop("handmax")
	local dc = hmax - #hand
	if dc<=0 then
		if LDEBUG then
			LOG:debug(LTAG, "skip drawHand")
		end
		return
	end
	local reuse = false
	local desk = self:getSet(Class.SET_DESK)
	for i=1,dc do
		local c0 = CSET.draw(desk)
		if not c0 then
			if not reuse then
				local discard = self:getSet(Class.SET_DISCARD)
				CSET.moveAll(desk, discard)
				CSET.shuffle(desk)
				reuse = true				
				cbd:uiEvent({t="reuse"})
				c0 = CSET.draw(desk)
				if LDEBUG then
					LOG:debug(LTAG, "%s reuse DISCARD", self:ToString())
				end
			end
		end		
		if not c0 then
			break
		end
		CSET.add(hand, c0)
		local ev = {
			t="move",
			k="draw",
			f=Class.SET_DESK,
			t=Class.SET_HAND,
			id=c0:prop("id")
		}
		cbd:uiEvent(ev)
		if LDEBUG then
			LOG:debug(LTAG, "%s drawHand %s",self:ToString(), c0:ToString())
		end
	end
end

------------------------
function Class:onCombatInit(cbd)	
end