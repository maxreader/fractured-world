--[[script.on_event(defines.events.on_chunk_generated, function(event)
    local radius = 30
    local position = event.position
    local surface = event.surface
    local thisProfiler = game.create_profiler()
    surface.request_to_generate_chunks(position, radius)
    surface.force_generate_chunk_requests()
    thisProfiler.stop()
    game.print(thisProfiler)
end) -- ]] 
