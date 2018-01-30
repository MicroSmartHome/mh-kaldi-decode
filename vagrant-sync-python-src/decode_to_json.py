#!/usr/bin/env python

import contextlib
import datetime as dt
import logging
import wave

# noinspection PyUnresolvedReferences
from kaldiasr.nnet3 import KaldiNNet3OnlineModel, KaldiNNet3OnlineDecoder
import plac
from pythonjsonlogger import jsonlogger
from pathlib2 import Path

from decoding import decode_wavs, KaldiNNet3OnlineDecoderMock

logger = logging.getLogger()


@plac.annotations(
    model_dir="Path to directory containing a Kaldi model.",
    model_name="Name of the Kaldi model to use. Must be the name of a "
               "subdirectory in 'model_dir'.",
    in_wav_dir=("Path to directory containing wav files to transcribe.",
                "positional", None, Path),
    out_dir=("Path to directory where transcriptions will be written to.",
             "positional", None, Path),
    dry_run=("Doesn't actually decode wav files with Kaldi, but instead uses a "
             "fake decoder. Useful for manually testing logging functionality.",
             "flag")
)
def main(model_dir, model_name, in_wav_dir, out_dir, dry_run):
    # type: (str, str, Path, Path, bool) -> None

    if dry_run:
        logger.info(dict(message="loading mock decoder"))
        decoder = KaldiNNet3OnlineDecoderMock()
    else:
        logger.info(dict(message="loading model",
                         model_dir=model_dir,
                         model_name=model_name))

        model = KaldiNNet3OnlineModel(model_dir, model_name)

        logger.info(dict(message="loading decoder"))
        decoder = KaldiNNet3OnlineDecoder(model)

    logger.info(dict(message="scanning directory for wav files",
                     in_wav_dir=str(in_wav_dir)))

    in_wavs = list(in_wav_dir.glob("*.wav"))

    logger.info(dict(message="scanned directory for wav files",
                     in_wav_dir=str(in_wav_dir),
                     n_wav_files=len(in_wavs)))

    decode_wavs(decoder, in_wavs, out_dir, get_utctime, get_wav_duration)


def get_utctime():
    return dt.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S,%f")


def get_wav_duration(wav):
    # type: (Path) -> float
    with contextlib.closing(wave.open(str(wav), 'r')) as f:
        frames = f.getnframes()
        rate = f.getframerate()
        duration = frames / float(rate)
    return duration


def log_format():
    # type: () -> str
    format_keys = [
        'asctime',
        'funcName',
        'levelname',
        'lineno',
        'message',
        'name',
        'pathname',
        'relativeCreated',
    ]
    custom_format = ' '.join(['%({0:s})'.format(i) for i in format_keys])
    return custom_format


if __name__ == "__main__":
    logHandler = logging.StreamHandler()
    formatter = jsonlogger.JsonFormatter(log_format())
    logHandler.setFormatter(formatter)
    logger.addHandler(logHandler)
    logger.setLevel(logging.INFO)

    plac.call(main)
