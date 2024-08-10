/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC
 */

import { CenteredText } from "../../Manufacturer/components/CenteredText";
import { Box, LabeledList, NumberInput, RoundGauge, Slider, Stack } from "../../../components";
import { toTitleCase } from 'common/string';
import { USE_PRESSURE } from '../constants';

interface PressureInfoProps {
  currentPressure:number;
  maxValue:number;
  formatContents: (value:number) => string;
  formatPressure: (value:number) => string;
  currentMoles:number;
  formatMatter: (value:number) => string;
  usePressure:boolean;
  advancedMode:boolean;
  width?:any;
  height?:any;
}

const PressureInfo = (props:PressureInfoProps) => {
  const {
    currentPressure,
    formatPressure,
    formatMatter,
    formatContents,
    currentMoles,
    maxValue,
    usePressure,
    advancedMode,
    width,
    height,
  } = props;

  const usedValue = usePressure ? currentPressure : currentMoles;

  if (advancedMode) {
    return (
      <Box
        width={width}
        height={height}
      >
        <LabeledList>
          <LabeledList.Item label="Pressure Values">
            {formatPressure(currentPressure)}
          </LabeledList.Item>
          <LabeledList.Item>
            {formatMatter(currentMoles)}
          </LabeledList.Item>
        </LabeledList>
      </Box>
    );
  }
  else {
    return (
      <Box
        width={width}
        height={height}
        align="center"
      >
        <RoundGauge
          value={usedValue}
          minValue={0} // vaccuum
          maxValue={maxValue}
          size={1.75}
          alertAfter={maxValue * 0.70}
          ranges={{
            "good": [0, maxValue * 0.70],
            "average": [maxValue * 0.70, maxValue * 0.85],
            "bad": [maxValue * 0.85, maxValue],
          }}
          format={formatContents}
        />
      </Box>
    );
  }
};

interface GasSettingProps {
  id:string;
  name:string;
  usedValue:number;
  maxValue:number;
  currentPressure:number;
  currentMoles:number;
  onNewPressure:(id:string, usedValue:number, newValue:number) => void;
  formatContents:(value:number) => string;
  formatPressure:(value:number) => string;
  formatMatter:(value:number) => string;
  unitContents:string;
  advancedMode:boolean;
}

export const GasSetting = (props:GasSettingProps) => {
  const {
    id,
    name,
    usedValue,
    maxValue,
    currentPressure,
    currentMoles,
    onNewPressure,
    formatContents,
    formatPressure,
    formatMatter,
    unitContents,
    advancedMode,
  } = props;

  // these intervals are based off mouse speed on my device because im cool and more important than everyone else
  const stepValue = (unitContents === USE_PRESSURE) ? 4 : 0.1; // kPa/step or moles/step

  return (
    <Stack>
      <Stack.Item
        fontSize={1.5}
        width={10}
        align="center"
      >
        <CenteredText text={toTitleCase(name)} />
      </Stack.Item>
      <Stack.Item
        width={advancedMode ? "50%" : "20%"}
      >
        <PressureInfo
          currentPressure={currentPressure}
          formatPressure={formatPressure}
          currentMoles={currentMoles}
          maxValue={maxValue}
          formatContents={formatContents}
          formatMatter={formatMatter}
          usePressure={unitContents === USE_PRESSURE}
          advancedMode={advancedMode}
          height={4}
        />
      </Stack.Item>
      <Stack.Item grow>
        {advancedMode ? (
          <NumberInput
            value={usedValue}
            minValue={0}
            maxValue={advancedMode ? undefined : maxValue}
            onChange={(_e:any, value:number) => { onNewPressure(id, usedValue, value); }}
            format={formatContents}
            width={"100%"}
          />
        ) : (
          <Slider
            value={usedValue}
            minValue={0}
            maxValue={advancedMode ? undefined : maxValue}
            onChange={(_e:any, value:number) => { onNewPressure(id, usedValue, value); }}
            format={formatContents}
            step={stepValue}
          />
        )}
      </Stack.Item>
    </Stack>
  );
};
