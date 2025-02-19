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
    public metadata: HashLocation | {primary: HashLocation, secondary: HashLocation} = { hash: '', location:''};

    @Property()
    public rawData: HashLocation | {primary: HashLocation, secondary: HashLocation} = { hash: '', location:''};

    @Property()
    public inputData ?: HashLocation;

    @Property()
    public inputMetadata?: HashLocation;

    @Property()
    public outputData?: HashLocation;

    @Property()
    public outputMetadata?: HashLocation;

    @Property()
    public siteName: string = '';

    @Property()
    public collaboratorName?: string;

    @Property()
    public orcid?: string;

    @Property()
    public accesUrl?: string;
}
