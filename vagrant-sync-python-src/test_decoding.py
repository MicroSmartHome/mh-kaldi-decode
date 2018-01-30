from mock import MagicMock
from pathlib2 import Path
from typing import Callable, List, Tuple

import decoding as mut


# noinspection PyClassHasNoInit
class TestDecodeWavs:
    def test_decode_wavs(self, caplog, tmpdir):
        # given
        mock_data = [
            (Path("path/rec-01.wav"), True, "hello world", -0.5),
            (Path("path/rec-02.wav"), False, "", 0.0),
            (Path("path/rec-03.wav"), True, "foo bar", -0.6)]

        decoder = create_kaldi_nnet3_online_decoder_mock(mock_data)
        get_utctime_mock = create_get_utctime_mock([
            "2018-01-30 13:00:00,1",
            "2018-01-30 13:00:00,2",
            "2018-01-30 13:00:00,3",

        ])

        get_wav_duration_mock = create_get_wav_duration_mock([12.0, 13.0, 14.0])

        in_wavs = [md[0] for md in mock_data]

        # when
        mut.decode_wavs(decoder, in_wavs, tmpdir, get_utctime_mock,
                        get_wav_duration_mock)

        # then
        actual_logs = [record.msg for record in caplog.records]
        assert actual_logs == [
            dict(message="decoding succeeded",
                 wav_file="path/rec-01.wav",
                 wav_duration_s=12.0,
                 likelihood=-0.5,
                 decoding_started_at="2018-01-30 13:00:00,1",
                 wav_nr=1),

            dict(message="decoding failed",
                 wav_file="path/rec-02.wav",
                 wav_duration_s=13.0,
                 decoding_started_at="2018-01-30 13:00:00,2",
                 wav_nr=2),

            dict(message="decoding succeeded",
                 wav_file="path/rec-03.wav",
                 wav_duration_s=14.0,
                 likelihood=-0.6,
                 decoding_started_at="2018-01-30 13:00:00,3",
                 wav_nr=3)]


# noinspection PyUnresolvedReferences
def create_kaldi_nnet3_online_decoder_mock(return_values):
    # type: (List[Tuple[Path,bool,str,float]]) -> KaldiNNet3OnlineDecoder

    decode_wav_file_vals = {}
    side_effects_get_decoded_string = []

    for wav_path, decoding_succeeded, transcript, likelihood in return_values:
        decode_wav_file_vals[str(wav_path)] = decoding_succeeded
        if decoding_succeeded:
            side_effects_get_decoded_string.append((transcript, likelihood))

    decoder = MagicMock()

    def side_effect_decode_wav_file(wav_path_):
        # Method KaldiNNet3OnlineDecoder.decode_wav_file() throws an exception
        # when its argument is not of type string, so we mimic this behavior.
        if type(wav_path_) != str:
            raise ValueError("Expected str")
        return decode_wav_file_vals[wav_path_]

    decoder.decode_wav_file = MagicMock(
        side_effect=side_effect_decode_wav_file)

    decoder.get_decoded_string = MagicMock(
        side_effect=side_effects_get_decoded_string)

    return decoder


def create_get_utctime_mock(timestamps_to_return):
    # type: (List[str]) -> Callable[[],str]
    get_utctime_mock = MagicMock(side_effect=timestamps_to_return)
    return get_utctime_mock


def create_get_wav_duration_mock(wav_durations):
    # type: (List[float]) -> Callable[[],float]
    get_wav_duration_mock = MagicMock(side_effect=wav_durations)
    return get_wav_duration_mock
