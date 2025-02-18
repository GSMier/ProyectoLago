/*
  SPDX-License-Identifier: Apache-2.0
*/

import {Object, Property} from 'fabric-contract-api';

interface HashLocation{
  hash: string;
  location: string
}

@Object()
export class ScientificData {

    @Property()
    public Id: string = '';

    @Property()
    public type: string = '';

    @Property()
    public generationDate: string = '';

    @Property()
    public metadata: HashLocation | {primary: string, secondary: string} = { hash: '', location:''};

    @Property()
    public rawData: string | {primary: string, secondary: string} = '';

    @Property()
    public inputData ?: string;

    @Property()
    public inputMetadata?: string;

    @Property()
    public outputData?: string;

    @Property()
    public outputMetadata?: string;

    @Property()
    public siteName: string = '';

    @Property()
    public collaboratorName?: string;

    @Property()
    public orcid?: string;

    @Property()
    public accesUrl?: string;
}
