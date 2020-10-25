function btg.Interpolate(a, b, coefficient)
	return a + (b - a) * coefficient
end

function btg.Clamp(i, min, max)
	return math.max(min, math.min(max, i))
end
