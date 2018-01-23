#!/usr/bin/env python

import glob
from os.path import join

from kaldiasr.nnet3 import KaldiNNet3OnlineModel, KaldiNNet3OnlineDecoder
import plac


@plac.annotations(
    model_dir="Path to directory containing a Kaldi model.",
    model_name="Name of the Kaldi model to use. Must be the name of a "
               "subdirectory in 'model_dir'.",
    wav_dir="Path to directory containing wav files to transcribe.")
def main(model_dir, model_name, wav_dir):
    print("Loading model.")
    model = KaldiNNet3OnlineModel(model_dir, model_name)
    print("Loading decoder.")
    decoder = KaldiNNet3OnlineDecoder(model)

    wavs = glob.glob(join(wav_dir, "*.wav"))

    for wav in wavs:
        print("Started decoding " + wav)
        if decoder.decode_wav_file(wav):

            print('%s decoding worked!' % model)

            s, l = decoder.get_decoded_string()
            print()
            print("*****************************************************************")
            print("**", s)
            print("** %s likelihood:" % model, l)
            print("*****************************************************************")
            print()

        else:
            print('%s decoding did not work :(' % model)


if __name__ == "__main__":
    plac.call(main)
