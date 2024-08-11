/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC
 */

import { CenteredText } from "../../Manufacturer/components/CenteredText";
import { Button } from "../../../components";

export const ConditionalSwitch = props => {
  const {
    enabled,
    callback,
    forceColor,
  } = props;

  const color = forceColor === "none" ? undefined : (enabled ? "green" : "red");

  return (
    <Button
      width={1.5}
      height={1.5}
      color={color}
      onClick={() => { callback(); }}
      verticalAlign="middle"
      disabled={!enabled}
    />
  );
};

export const LabeledSwitch = props => {
  const {
    text,
    height,
    callback,
    enabled,
    forceColor,
  } = props;
  return (
    <>
      <CenteredText
        width={"80%"}
        height={height}
        text={text}
      />
      <Switch callback={callback} enabled={enabled} forceColor={forceColor} />
    </>
  );
};

export const Switch = (props:SwitchProps) => {
  const {
    enabled,
    callback,
    forceColor,
  } = props;

  const color = forceColor === "none" ? undefined : (enabled ? "green" : "red");

  return (
    <Button
      width={1.5}
      height={1.5}
      color={color}
      onClick={() => { callback(); }}
      verticalAlign="middle"
    />
  );
};
