import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../Provider/provider.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying(
      {super.key, required this.songModelList, required this.audioPlayer});
  //final SongModel songModel;
  final List<SongModel> songModelList;
  final AudioPlayer audioPlayer;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool _isPlaying = false;
  List<AudioSource> songList = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    //playSong();
    parseSong();
  }

  // void playSong() {
  //   try {
  //     widget.audioPlayer
  //         .setAudioSource(AudioSource.uri(Uri.parse(widget.songModel.uri!)));
  //     widget.audioPlayer.play();
  //     _isPlaying = true;
  //   } on Exception catch (e) {
  //     print("Error loading audio source: $e");
  //   }
  //   widget.audioPlayer.durationStream.listen((d) {
  //     setState(() {
  //       _duration = d!;
  //     });
  //   });
  //   widget.audioPlayer.positionStream.listen((p) {
  //     setState(() {
  //       _position = p;
  //     });
  //   });
  // }

  void parseSong() {
    try {
      for (var element in widget.songModelList) {
        songList.add(
          AudioSource.uri(Uri.parse(element.uri!)),
        );
      }

      widget.audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: songList),
      );
      widget.audioPlayer.play();
      _isPlaying = true;

      widget.audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });
      widget.audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
      listenToEvent();
      listenToSongIndex();
    } on Exception catch (_) {
      Navigator.pop(context);
    }
  }

  void listenToEvent() {
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          _isPlaying = true;
        });
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void listenToSongIndex() {
    widget.audioPlayer.currentIndexStream.listen(
      (event) {
        setState(
          () {
            if (event != null) {
              currentIndex = event;
            }
            context
                .read<SongModelProvider>()
                .setId(widget.songModelList[currentIndex].id);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            if (_isPlaying) {
                              widget.audioPlayer.stop();
                            }
                          });
                        },
                        icon: Icon(Icons.arrow_back)),
                    const Text(
                      "Now Playing",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 20,
                  ),
                  const Center(
                    child: CircleAvatar(
                      radius: 140,
                      child: Icon(
                        Icons.music_note_sharp,
                        size: 80,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    //widget.songModel.displayNameWOExt,
                    widget.songModelList[currentIndex].displayNameWOExt,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    //widget.songModel.artist.toString(),
                    widget.songModelList[currentIndex].artist.toString(),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Text(_position.toString().split(".")[0]),
                      Expanded(
                          child: Slider(
                              min: Duration(microseconds: 0)
                                  .inSeconds
                                  .toDouble(),
                              max: _duration.inSeconds.toDouble(),
                              value: _position.inSeconds.toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  changetoSec(value.toInt());
                                  value = value;
                                });
                              })),
                      Text(_duration.toString().split(".")[0]),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.repeat),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (widget.audioPlayer.hasPrevious) {
                              widget.audioPlayer.seekToPrevious();
                            }
                          });
                        },
                        icon: Icon(Icons.skip_previous),
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_isPlaying) {
                              widget.audioPlayer.pause();
                            } else {
                              widget.audioPlayer.play();
                            }
                            _isPlaying = !_isPlaying;
                          });
                        },
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (widget.audioPlayer.hasNext) {
                              widget.audioPlayer.seekToNext();
                            }
                          });
                        },
                        icon: Icon(Icons.skip_next),
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.shuffle),
                      ),
                    ],
                  )
                ],
              ))),
    );
  }

  void changetoSec(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}
