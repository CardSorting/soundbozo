return {
    name = "ハンバーグパラダイス!",
    audio = "assets/ハンバーグパラダイス!.mp3",
    difficulty = "Medium",
    bpm = 120,
    pattern = {
        -- Base cooking rhythm
        {time = 0.5, type = "note", lane = 1},
        {time = 1.0, type = "note", lane = 2},
        {time = 1.5, type = "note", lane = 3},
        {time = 2.0, type = "note", lane = 4},
        {time = 2.5, type = "note", lane = 1},
        {time = 3.0, type = "note", lane = 2},
        {time = 3.5, type = "note", lane = 3},
        {time = 4.0, type = "note", lane = 4},
        
        -- First burger layer (bun) at 8 seconds
        {time = 8.0, type = "note", lane = 1},
        {time = 8.1, type = "note", lane = 4},
        {time = 8.2, type = "note", lane = 2},
        {time = 8.3, type = "note", lane = 3},
        
        -- Second layer (patty) at 16 seconds
        {time = 16.0, type = "note", lane = 2},
        {time = 16.1, type = "note", lane = 3},
        {time = 16.2, type = "note", lane = 1},
        {time = 16.3, type = "note", lane = 4},
        
        -- Toppings layers every 8 seconds
        {time = 24.0, type = "note", lane = 3},
        {time = 24.1, type = "note", lane = 2},
        {time = 24.2, type = "note", lane = 4},
        {time = 24.3, type = "note", lane = 1},
        
        {time = 32.0, type = "note", lane = 4},
        {time = 32.1, type = "note", lane = 1},
        {time = 32.2, type = "note", lane = 3},
        {time = 32.3, type = "note", lane = 2},
        
        -- Final bun layer at 40 seconds
        {time = 40.0, type = "note", lane = 1},
        {time = 40.1, type = "note", lane = 4},
        {time = 40.2, type = "note", lane = 2},
        {time = 40.3, type = "note", lane = 3},
        
        -- Cooking rhythm continues to 60 seconds
        {time = 41.0, type = "note", lane = 2},
        {time = 41.5, type = "note", lane = 3},
        {time = 42.0, type = "note", lane = 4},
        {time = 42.5, type = "note", lane = 1},
        {time = 43.0, type = "note", lane = 2},
        {time = 43.5, type = "note", lane = 3},
        {time = 44.0, type = "note", lane = 4},
        {time = 44.5, type = "note", lane = 1},
        
        -- Continue this pattern up to 60 seconds...
        {time = 59.0, type = "note", lane = 2},
        {time = 59.5, type = "note", lane = 3},
        {time = 60.0, type = "note", lane = 4}
    }
}
