
import { Button, Collapsible, LabeledList, Section, Stack } from "../../../components";
import { SubmenuProps } from "../type";
import { formatKelvinAs, formatMolesAs, formatPascalsAs } from '../Util';
import { USE_PRESSURE, SYMBOL_DELTA } from '../constants';

const log = (act:(action:string, props?:Record<string, string|number|boolean>) => void, data:string|number|boolean) => {
  act("console_log", { data: data });
};

const GasPacketData = (props) => {
  const {
    friendlyFormatTemperature,
    friendlyFormatMatter,
    packet,
  } = props;

  const gasNames = ['O2', 'N2', 'CO2', 'Plasma', 'Farts', 'Fallout', 'N20', 'Oxygen Agent B'];
  const gasIDs = ['oxygen', 'nitrogen', 'carbon_dioxide', 'toxins', 'farts', 'radgas', 'nitrous_oxide', 'oxygen_agent_b'];

  return (
    <LabeledList>
      {gasIDs.map((id, index) => {
        return (
          <LabeledList.Item key={index} label={gasNames[index]}>
            {friendlyFormatMatter(packet[id])}
          </LabeledList.Item>
        );
      })}
      <LabeledList.Item label={"Temperature"}>
        {friendlyFormatTemperature(packet.temperature)}
      </LabeledList.Item>
      <LabeledList.Item label={"Volume"}>
        {packet.volume} Litres
      </LabeledList.Item>
    </LabeledList>
  );
};

const LogEntryData = (props) => {

  const {
    friendlyFormatTemperature,
    friendlyFormatMatter,
    log_entry,
  } = props;

  return (
    <LabeledList>
      <Section title={"Before reaction:"}>
        <GasPacketData
          packet={log_entry.pre}
          friendlyFormatTemperature={friendlyFormatTemperature}
          friendlyFormatMatter={friendlyFormatMatter}
        />
      </Section>
      <Section title={"After reaction:"}>
        <GasPacketData
          packet={log_entry.post}
          friendlyFormatTemperature={friendlyFormatTemperature}
          friendlyFormatMatter={friendlyFormatMatter}
        />
      </Section>
    </LabeledList>
  );
};

export const LogOutput = (props:SubmenuProps) => {
  const { act, data } = props;

  const usePressure = data.si_unit_used_contents === 'pressure';
  const unitContents = usePressure ? data.use_pressure_unit : data.use_matter_unit;
  const usedValue = usePressure ? data.gas_data.total_pressure : data.gas_data.total_moles;
  // These are a bit more complicated, so as an exception it gets its own direct ref to the formatting function
  const usedFormatContents = (data.si_unit_used_contents === USE_PRESSURE) ? formatPascalsAs : formatMolesAs;
  const maxValue = usePressure ? data.max_pressure : data.max_moles;

  const friendlyFormatContents = value => { return usedFormatContents(unitContents, value); };
  const friendlyFormatTemperature = value => { return formatKelvinAs(data.use_temperature_unit, value); };
  const friendlyFormatPressure = value => { return formatPascalsAs(data.use_pressure_unit, value); };
  const friendlyFormatMatter = value => { return formatMolesAs(data.use_matter_unit, value); };

  let dummy_act = (action:string, props?:Record<string, string|number|boolean>) => { return; };
  const do_logs = false;
  if (do_logs) { dummy_act = act; }

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack height={2} >
          <Stack.Item width="20%">
            <Button onClick={act("clear_logs")} >
              Clear Logs
            </Button>
          </Stack.Item>
          <Stack.Item width="20%">

          </Stack.Item>
          <Stack.Item width="20%">

          </Stack.Item>
          <Stack.Item width="20%">

          </Stack.Item>
          <Stack.Item width="20%">

          </Stack.Item>
        </Stack>
      </Stack.Item>
      {data.log_data.map((log_entry, index) => {
        return (
          <Collapsible key={index} title={`Packet ${index}`}>
            <Stack.Item>
              <Section>
                <LogEntryData log_entry={log_entry}
                  friendlyFormatTemperature={friendlyFormatTemperature}
                  friendlyFormatMatter={friendlyFormatMatter}
                />
              </Section>
            </Stack.Item>
          </Collapsible>
        );
      })}
    </Stack>
  );
};
