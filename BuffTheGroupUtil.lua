btgUtil = {}

function btgUtil.Interpolate(a, b, coefficient)
	return a + (b - a) * coefficient
end

function btgUtil.Clamp(i, min, max)
	return math.max(min, math.min(max, i))
end

function btgUtil.FillTable(length, value)
	local t = {}
	for i = 1, length do
		table.insert(t, value)
	end
	return t
end
