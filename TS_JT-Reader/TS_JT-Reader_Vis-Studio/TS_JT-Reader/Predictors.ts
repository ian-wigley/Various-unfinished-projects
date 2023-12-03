﻿module C_sharp_JT_Reader.Codecs {
    export class Predictors {
        constructor() {

        }
        public static unpackResiduals(residuals: number[], predType: PredictorType): number[] {
            var predicted: number;
            var len: number = residuals.length;
            var primals: number[] = new Array(len);
            for (var i: number = 0; i < len; i++)
                if (i < 4)
                    primals[i] = residuals[i];
                else {
                    predicted = Predictors.predictValue(primals, i, predType);
                    if (predType == PredictorType.Xor1 || predType == PredictorType.Xor2)
                        primals[i] = residuals[i] ^ predicted;
                    else primals[i] = residuals[i] + predicted;
                }
            return primals;
        }
        public static unpackResidualsOverwrite(residuals: number[], predType: PredictorType): number[] {
            var predicted: number;
            var len: number = residuals.length;
            for (var i: number = 0; i < len; i++) {
                if (i < 4) {
                    residuals[i] = residuals[i];
                }
                else {
                    predicted = Predictors.predictValue(residuals, i, predType);
                    if (predType == PredictorType.Xor1 || predType == PredictorType.Xor2) {
                        residuals[i] = residuals[i] ^ predicted;
                    }
                    else {
                        residuals[i] = residuals[i] + predicted;
                    }
                }
            }
            return residuals;
        }
        public static predictValue(primals: number[], index: number, predType: PredictorType): number {
            var predicted: number;
            var v1: number = primals[index - 1];
            var v2: number = primals[index - 2];
            var v3: number = primals[index - 3];
            var v4: number = primals[index - 4];
            switch (predType) {
                default:
                case PredictorType.Lag1:
                case PredictorType.Xor1:
                    predicted = v1;
                    break;
                case PredictorType.Lag2:
                case PredictorType.Xor2:
                    predicted = v2;
                    break;
                case PredictorType.Stride1:
                    predicted = v1 + (v1 - v2);
                    break;
                case PredictorType.Stride2:
                    predicted = v2 + (v2 - v4);
                    break;
                case PredictorType.StripIndex:
                    if (v2 - v4 < 8 && v2 - v4 > -8) {
                        predicted = v2 + (v2 - v4);
                    }
                    else {
                        predicted = v2 + 2;
                    }
                    break;
                case PredictorType.Ramp:
                    predicted = index;
                    break;
            }
            return predicted;
        }
    }
    export module Predictors {
        export enum PredictorType {
            Lag1,
            Lag2,
            Stride1,
            Stride2,
            StripIndex,
            Ramp,
            Xor1,
            Xor2,
            NULL
        }
    }
}