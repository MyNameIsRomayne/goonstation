/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { ConditionalSwitch, LabeledSwitch } from './components/Switch';
import { GasSetting } from './components/GasSettings';
import { AnimatedNumber, Divider, Icon, LabeledList, RoundGauge, Stack } from "../../components";
import { Window } from '../../layouts';
import { getTemperatureColor, getTemperatureIcon } from '../common/temperatureUtils';
import { formatKelvinAs, formatMolesAs, formatPascalsAs } from './Util';
import { UNIT_CELSIUS, UNIT_FARENHEIT, UNIT_KELVIN, UNIT_MOLES, UNIT_PASCALS, USE_MATTER, USE_PRESSURE } from './constants';

interface GasInfoOverview {
  // Basic gas collection information
  total_pressure:number;
  total_moles:number;
  temperature:number;
  volume:number;
  // Specific gas information
  data_each_gas:Array<GasData>;
}

interface DevBombSimData {
  // Specific gas information
  gas_data:GasInfoOverview;
  max_moles:number;
  // Consts/Config
  advanced_mode: boolean;
  use_temperature_unit: 'kelvin' | 'celsius' | 'farenheit';
  use_pressure_unit: 'pascals';
  use_matter_unit: 'moles';
  si_unit_used_contents: 'pressure' | 'matter';
  max_pressure: number;
}

interface GasData {
  name:string;
  id:string;
  moles:number;
  kPa:number;
}

interface UnitSelectionData {
  label:string;
  callback:() => void;
  enabled:boolean;
}

interface GasOverviewProps {
  usedValue:number;
  maxValue:number;
  temperature:number;
  formatContents:(value:number) => string;
  formatTemperature:(value:number) => string;
}

const GasOverview = (props:GasOverviewProps) => {
  const {
    usedValue,
    maxValue,
    formatContents,
    formatTemperature,
    temperature,
  } = props;

  return (
    <Stack>
      <Stack.Item>
        <RoundGauge
          value={usedValue}
          minValue={0}
          maxValue={maxValue}
          format={formatContents}
          alertAfter={maxValue}
          ranges={{
            "good": [0, maxValue * 0.70],
            "average": [maxValue * 0.70, maxValue * 0.85],
            "bad": [maxValue * 0.85, maxValue],
          }}
        />
      </Stack.Item>

      <Stack.Item
        color={getTemperatureColor(temperature)}
      >
        <Icon name={getTemperatureIcon(temperature)} pr={0.5} />
        <AnimatedNumber value={temperature} format={formatTemperature} />
      </Stack.Item>
    </Stack>
  );
};

export const DevBombSim = (_, context) => {
  const { act, data } = useBackend<DevBombSimData>(context);

  const adjustPressure = (gasID:string, currentPressure:number, newPressure:number) => {
    if (currentPressure === newPressure) {
      return;
    }
    act("set_pressure", { name: gasID, pressure: newPressure });
  };

  const setUsedSIUnitContents = (newUnit:string) => {
    act("change_used_si_unit_contents", { unit: newUnit });
  };

  const setUnit = (newUnit:string) => {
    act("set_unit", { unit: newUnit });
  };

  const toggleAdvancedMode = () => {
    act("toggle_advanced_mode");
  };

  const doReactionStep = () => {
    act("do_reaction_step");
  };

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

  const unitOptions:Array<UnitSelectionData> = [
    {
      label: "Set contents unit to Matter",
      callback: (() => setUsedSIUnitContents(USE_MATTER)),
      enabled: (data.si_unit_used_contents === USE_PRESSURE),
    },
    {
      label: "Set contents unit to Pressure",
      callback: (() => setUsedSIUnitContents(USE_PRESSURE)),
      enabled: (data.si_unit_used_contents === USE_MATTER),
    },
    {
      label: "Set matter to Moles",
      callback: (() => setUnit(UNIT_MOLES)),
      enabled: (data.use_matter_unit !== UNIT_MOLES),
    },
    {
      label: "Set pressure to Pascals",
      callback: (() => setUnit(UNIT_PASCALS)),
      enabled: (data.use_pressure_unit !== UNIT_PASCALS),
    },
    {
      label: "Set temperature to Kelvin",
      callback: (() => setUnit(UNIT_KELVIN)),
      enabled: (data.use_temperature_unit !== UNIT_KELVIN),
    },
    {
      label: "Set temperature to Celsius",
      callback: (() => setUnit(UNIT_CELSIUS)),
      enabled: (data.use_temperature_unit !== UNIT_CELSIUS),
    },
    {
      label: "Set temperature to Farenheit",
      callback: (() => setUnit(UNIT_FARENHEIT)),
      enabled: (data.use_temperature_unit !== UNIT_FARENHEIT),
    },
  ];

  return (
    <Window height={900} width={700}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Stack height={15}>
              <Stack.Item width="33%">
                <LabeledSwitch
                  text={"Toggle Advanced Mode"}
                  height={5}
                  callback={() => toggleAdvancedMode()}
                  enabled={data.advanced_mode}
                />
              </Stack.Item>
              <Stack.Item width="33%">
                <LabeledList>
                  {unitOptions.map((value, index:number) => {
                    return (
                      <LabeledList.Item
                        key={index}
                        label={value.label}
                        buttons={
                          [<ConditionalSwitch key={0} enabled={value.enabled} callback={() => value.callback()} />]
                        }
                      />
                    );
                  })}
                </LabeledList>
              </Stack.Item>
              <Stack.Item width="33%">
                <LabeledSwitch
                  text={"Do reaction step"}
                  height={5}
                  callback={() => doReactionStep()}
                  forceColor={"none"}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            {data.use_temperature_unit}
            <GasOverview
              usedValue={usedValue}
              maxValue={maxValue}
              formatContents={friendlyFormatContents}
              formatTemperature={friendlyFormatTemperature}
              temperature={data.gas_data.temperature}
            />
          </Stack.Item>
          <Divider />
          {data.gas_data.data_each_gas.map((gas:GasData, i:number) => {
            return (
              <Stack.Item key={i}>
                <GasSetting
                  id={gas.id}
                  name={gas.name}
                  usedValue={usedValue}
                  maxValue={maxValue}
                  currentPressure={gas.kPa}
                  currentMoles={gas.moles}
                  onNewPressure={adjustPressure}
                  formatContents={friendlyFormatContents}
                  formatPressure={friendlyFormatPressure}
                  formatMatter={friendlyFormatMatter}
                  unitContents={unitContents}
                  advancedMode={data.advanced_mode}
                />
                <Divider />
              </Stack.Item>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};
