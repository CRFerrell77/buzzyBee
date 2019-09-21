tool
extends AudioStreamPlayer #exactly the same code should work for extending 2D and 3D versions
class_name RoundRobinPlayer

export(int, "sequence", "random", "shuffle") var queue_mode = 0
export(Array, AudioStream) var playlist = [] setget _set_playlist, _get_playlist
export(bool) var round_robin_playing = false setget _set_playing, _is_playing # can't override properties so use this for animations

var playlist_index = -1 # current position in the playlist
var shuffled_indices = [] # Array<int> of shuffled playlist indices

func _init():
	randomize() #it needs to be called here so the rng is randomized by the time the setters are called. 

func get_next_stream():
	if playlist.empty():
		return
	match queue_mode:
		0: 
			stream = _get_next_sequence_mode()
		1:
			stream = _get_next_random_mode()
		2:
			stream = _get_next_shuffle_mode()
	pass
	
# Gets the next stream in the playlist
func _get_next_sequence_mode():
	playlist_index = wrapi(playlist_index+1, 0, playlist.size())
	return playlist[playlist_index]
	pass

# Gets a random stream from the playlist.
# Can be the same as the last one.
# Yes, it has modulo bias. I don't thing it really matters for this application
func _get_next_random_mode():
	return playlist[randi()%playlist.size()]
	pass

# Gets the next stream in a randomized list of size playlist.size()
# When the list is exhausted it is reshuffled
func _get_next_shuffle_mode():
	print("get next shuffle")
	playlist_index += 1
	print("Playlist_index: %s" % playlist_index)
	if playlist_index >= playlist.size():
		shuffled_indices.shuffle()
		playlist_index = 0
	print(playlist[shuffled_indices[playlist_index]])
	return playlist[shuffled_indices[playlist_index]]
	pass
	
	
func play(from_position:float = 0.0):
	get_next_stream()
	.play(from_position)
	pass

func _set_playing(is_true):
	if is_true:
		get_next_stream()
	._set_playing(is_true)

func _is_playing():
	return .is_playing()

func _set_playlist(plist):
	playlist_index = -1
	playlist = plist
	shuffled_indices = range( playlist.size() )
	shuffled_indices.shuffle()
	get_next_stream()
	
func _get_playlist():
	return playlist


func _on_background_music_finished():
	get_next_stream()
	.play()
	pass # Replace with function body.
