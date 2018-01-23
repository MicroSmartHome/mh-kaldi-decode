#!/usr/bin/env python

from kaldiasr.nnet3 import KaldiNNet3OnlineModel, KaldiNNet3OnlineDecoder

MODELDIR    = '/home/mpuels/mh-kaldi-models/kaldi-chain-voxforge-de-r20180119'
MODEL       = 'nnet_tdnn_sp'
WAVFILE     = '/home/mpuels/projects/py-kaldi-asr/data/single.wav'

model   = KaldiNNet3OnlineModel   (MODELDIR, MODEL)
decoder = KaldiNNet3OnlineDecoder (model)

if decoder.decode_wav_file(WAVFILE):

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
