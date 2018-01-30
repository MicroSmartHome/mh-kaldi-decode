import json
import logging

from typing import Callable, List, Tuple
from pathlib2 import Path

logger = logging.getLogger(__file__)


class KaldiNNet3OnlineDecoderMock:
    def __init__(self):
        self.n_calls_decode_wav_file = -1

    def decode_wav_file(self, wav_path):
        # type: (str) -> bool
        self.n_calls_decode_wav_file += 1
        if self.n_calls_decode_wav_file % 2 == 0:
            return True
        else:
            return False

    @staticmethod
    def get_decoded_string():
        # type: () -> Tuple[str,float]
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit", -0.4


# noinspection PyUnresolvedReferences
def decode_wavs(decoder,  # type: KaldiNNet3OnlineDecoder
                in_wavs,  # type: List[Path]
                out_dir,  # type: Path
                get_utctime_func,  # type: Callable[[],str]
                get_wav_duration_func  # type: Callable[[Path],float]
                ):
    # type: (...) -> None
    for wav_nr, wav in enumerate(in_wavs):
        wav_duration_s = get_wav_duration_func(wav)
        decoding_started_at = get_utctime_func()
        if decoder.decode_wav_file(str(wav)):
            transcription, likelihood = decoder.get_decoded_string()
            logger.info(dict(wav_file=str(wav),
                             message="decoding succeeded",
                             likelihood=likelihood,
                             decoding_started_at=decoding_started_at,
                             wav_duration_s=wav_duration_s,
                             wav_nr=wav_nr + 1))
            out_file_path = out_dir / Path(wav.stem + ".json")
            with open(str(out_file_path), "wt") as f:
                json.dump({"likelihood": likelihood,
                           "transcription": transcription},
                          f)
        else:
            logger.info(dict(message="decoding failed",
                             wav_file=str(wav),
                             decoding_started_at=decoding_started_at,
                             wav_duration_s=wav_duration_s,
                             wav_nr=wav_nr + 1))
