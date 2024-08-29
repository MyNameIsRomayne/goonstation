
import { ConditionalSwitch, LabeledSwitch, Switch } from '../components/Switch';
import { GasSetting } from '../components/GasSettings';
import { AnimatedNumber, Divider, Icon, LabeledList, NumberInput, RoundGauge, Slider, Stack } from "../../../components";
import { getTemperatureColor, getTemperatureIcon } from '../../common/temperatureUtils';
import { conversionFunctionsTemperature, formatKelvinAs, formatMolesAs, formatPascalsAs } from '../Util';
import { UNIT_CELSIUS, UNIT_FARENHEIT, UNIT_KELVIN, USE_MATTER, USE_PRESSURE } from '../constants';
import { GasData, GasOverviewProps, SubmenuProps, UnitSelectionData } from '../type';

export const TankBuilder = (props:SubmenuProps) => {
  const {
    act,
    data,
  } = props;

  const adjustContents = (gasID:string, useContents:typeof USE_MATTER|typeof USE_PRESSURE, newValue:number) => {
    if (useContents === USE_MATTER) {
      act("set_matter", { name: gasID, matter: newValue });
      return;
    }
    if (useContents === USE_PRESSURE) {
      act("set_pressure", { name: gasID, pressure: newValue });
      return;
    }
  };

  const setUsedSIUnitContents = (newUnit:string) => {
    act("change_used_si_unit_contents", { unit: newUnit });
  };

  const setTemperature = (newValue:number) => {
    act("set_temperature", { unit: data.use_temperature_unit, value: newValue });
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

  const doMaxReactionSteps = () => {
    act("reaction_steps_until_stable");
  };

  const makeTank = (setloc:boolean) => {
    act("copy_into_tank", { set_loc: setloc });
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
      label: "Contents → Matter",
      callback: (() => setUsedSIUnitContents(USE_MATTER)),
      enabled: (data.si_unit_used_contents === USE_PRESSURE),
    },
    {
      label: "Contents → Pressure",
      callback: (() => setUsedSIUnitContents(USE_PRESSURE)),
      enabled: (data.si_unit_used_contents === USE_MATTER),
    },
    /* This code works as of the time of writing, but is useless as there is only one matter/pressure unit
      supported. Uncomment if more are added, and **DO NOT REMOVE**
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
    */
    {
      label: "Temp → Kelvin",
      callback: (() => setUnit(UNIT_KELVIN)),
      enabled: (data.use_temperature_unit !== UNIT_KELVIN),
    },
    {
      label: "Temp → Celsius",
      callback: (() => setUnit(UNIT_CELSIUS)),
      enabled: (data.use_temperature_unit !== UNIT_CELSIUS),
    },
    {
      label: "Temp → to Farenheit",
      callback: (() => setUnit(UNIT_FARENHEIT)),
      enabled: (data.use_temperature_unit !== UNIT_FARENHEIT),
    },
  ];

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack height={10}>
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
            <LabeledList>
              <LabeledList.Item label="Do reaction step">
                <Switch
                  callback={() => doReactionStep()}
                  forceColor={"none"}
                  enabled
                />
              </LabeledList.Item>
              <LabeledList.Item label="React until inert">
                <Switch
                  callback={() => doMaxReactionSteps()}
                  forceColor={"none"}
                  enabled
                />
              </LabeledList.Item>
              <LabeledList.Item label="Spawn tank on self">
                <Switch
                  callback={() => makeTank(true)}
                  forceColor={"none"}
                  enabled
                />
              </LabeledList.Item>
              <LabeledList.Item label="Spawn tank in nullspace">
                <Switch
                  callback={() => makeTank(false)}
                  forceColor={"none"}
                  enabled
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Divider />
      <Stack.Item>
        <GasOverview
          usedValue={usedValue}
          maxValue={maxValue}
          formatContents={friendlyFormatContents}
          formatTemperature={friendlyFormatTemperature}
          onChangeTemperature={setTemperature}
          temperature={data.gas_data.temperature}
          temperatureUnit={data.use_temperature_unit}
          advancedMode={data.advanced_mode}
        />
      </Stack.Item>
      <Divider />
      {data.gas_data.data_each_gas.map((gas:GasData, i:number) => {
        return (
          <Stack.Item key={i}>
            <GasSetting
              id={gas.id}
              name={gas.name}
              usedValue={(data.si_unit_used_contents === USE_PRESSURE) ? gas.pascals : gas.moles}
              maxValue={maxValue}
              currentPressure={gas.pascals}
              currentMoles={gas.moles}
              onNewPressure={adjustContents}
              formatContents={friendlyFormatContents}
              formatPressure={friendlyFormatPressure}
              formatMatter={friendlyFormatMatter}
              unitContents={unitContents}
              siUnitContents={data.si_unit_used_contents}
              advancedMode={data.advanced_mode}
            />
            <Divider />
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

const GasOverview = (props:GasOverviewProps) => {
  const {
    usedValue,
    maxValue,
    formatContents,
    formatTemperature,
    onChangeTemperature,
    temperature,
    temperatureUnit,
    advancedMode,
  } = props;

  const minTemperatureValue = conversionFunctionsTemperature[temperatureUnit](0);

  return (
    <Stack>
      <Stack.Item width="33%">
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
        width="33%"
        fontSize={1.5}
      >
        <Icon name={getTemperatureIcon(temperature)} pr={0.5} />
        <AnimatedNumber value={temperature} format={formatTemperature} />
      </Stack.Item>
      <Stack.Item width="33%">
        {advancedMode ? (
          <NumberInput
            width={"100%"}
            value={temperature}
            minValue={minTemperatureValue} // dont break the fabric of reality without dev overrides
            maxValue={undefined}
            onChange={(_e:any, value:number) => onChangeTemperature(value)}
            format={formatTemperature}
          />
        ) : (
          <Slider
            value={temperature}
            minValue={minTemperatureValue}
            maxValue={10000} // arbitrary, doesnt matter for advanced mode anyways
            onChange={(_e:any, value:number) => onChangeTemperature(value)}
            format={formatTemperature}
          />
        )}
      </Stack.Item>
    </Stack>
  );
};
