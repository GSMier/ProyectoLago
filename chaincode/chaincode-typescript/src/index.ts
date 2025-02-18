/*
 * SPDX-License-Identifier: Apache-2.0
 */

import {type Contract} from 'fabric-contract-api';
import {ScientificDataCollectContract} from './scientificDataCollect';

export const contracts: typeof Contract[] = [ScientificDataCollectContract];
