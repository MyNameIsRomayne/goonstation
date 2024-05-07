/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Collapsible, Input, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type ReaderData = {
  var_data: Record<string, VarInfo[]>;
}

type VarInfo = {
  name:string;
  value:string;
  islist:boolean;
  istype:boolean;
}

export const VarReader = (_, context) => {
  const { act, data } = useBackend<ReaderData>(context);
  let var_data_keys = (data.var_data !== null) ? Object.keys(data.var_data).reverse() : null;
  return (
    <Window title="VarReader 9000">
      <Window.Content>
        <Input
          onChange={(_, newVal) => act("query", { "path": newVal })}
          width="100%"
          placeholder="Search any absolute path here..."
        />

        {(var_data_keys !== null) && var_data_keys.map((key:string) => (
          <Section key={key}>
            <Collapsible title={key} open>
              <LabeledList>
                {(key !== null) && data.var_data[key].map((vardata:VarInfo, i) => (
                  <LabeledList.Item
                    key={i}
                    label={vardata.name}
                  >
                    {(vardata.value === '' ? "null" : vardata.value)}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Collapsible>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};


