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
          size={1.25}
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
    siUnitContents,
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
          usePressure={siUnitContents === USE_PRESSURE}
          advancedMode={advancedMode}
        />
      </Stack.Item>
      <Stack.Item grow>
        {advancedMode ? (
          <NumberInput
            value={usedValue}
            minValue={0}
            maxValue={advancedMode ? undefined : maxValue}
            onChange={(_e:any, value:number) => { onNewPressure(id, siUnitContents, value); }}
            format={formatContents}
            width={"100%"}
          />
        ) : (
          <Slider
            value={usedValue}
            minValue={0}
            maxValue={advancedMode ? undefined : maxValue}
            onChange={(_e:any, value:number) => { onNewPressure(id, siUnitContents, value); }}
            format={formatContents}
            step={stepValue}
          />
        )}
      </Stack.Item>
    </Stack>
  );
};
