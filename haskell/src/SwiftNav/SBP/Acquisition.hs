{-# OPTIONS_GHC -fno-warn-unused-imports #-}
-- |
-- Module:      SwiftNav.SBP.Acquisition
-- Copyright:   Copyright (C) 2015 Swift Navigation, Inc.
-- License:     LGPL-3
-- Maintainer:  Mark Fine <dev@swiftnav.com>
-- Stability:   experimental
-- Portability: portable
--
-- Satellite acquisition messages from the device.

module SwiftNav.SBP.Acquisition where

import BasicPrelude
import Control.Lens
import Control.Monad.Loops
import Data.Aeson.TH           (defaultOptions, deriveJSON, fieldLabelModifier)
import Data.Binary
import Data.Binary.Get
import Data.Binary.IEEE754
import Data.Binary.Put
import Data.ByteString
import Data.ByteString.Lazy    hiding (ByteString)
import Data.Int
import Data.Word
import SwiftNav.SBP.Encoding
import SwiftNav.SBP.TH
import SwiftNav.SBP.Types
import SwiftNav.SBP.GnssSignal

msgAcqResult :: Word16
msgAcqResult = 0x0014

-- | SBP class for message MSG_ACQ_RESULT (0x0014).
--
-- This message describes the results from an attempted GPS signal acquisition
-- search for a satellite PRN over a code phase/carrier frequency range. It
-- contains the parameters of the point in the acquisition search space with
-- the best signal-to-noise (SNR) ratio.
data MsgAcqResult = MsgAcqResult
  { _msgAcqResult_snr :: Float
    -- ^ SNR of best point. Currently in arbitrary SNR points, but will be in
    -- units of dB Hz in a later revision of this message.
  , _msgAcqResult_cp :: Float
    -- ^ Code phase of best point
  , _msgAcqResult_cf :: Float
    -- ^ Carrier frequency of best point
  , _msgAcqResult_sid :: GnssSignal
    -- ^ GNSS signal for which acquisition was attempted
  } deriving ( Show, Read, Eq )

instance Binary MsgAcqResult where
  get = do
    _msgAcqResult_snr <- getFloat32le
    _msgAcqResult_cp <- getFloat32le
    _msgAcqResult_cf <- getFloat32le
    _msgAcqResult_sid <- get
    return MsgAcqResult {..}

  put MsgAcqResult {..} = do
    putFloat32le _msgAcqResult_snr
    putFloat32le _msgAcqResult_cp
    putFloat32le _msgAcqResult_cf
    put _msgAcqResult_sid

$(deriveSBP 'msgAcqResult ''MsgAcqResult)

$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_msgAcqResult_" . stripPrefix "_msgAcqResult_"}
             ''MsgAcqResult)
$(makeLenses ''MsgAcqResult)

msgAcqResultDepA :: Word16
msgAcqResultDepA = 0x0015

-- | SBP class for message MSG_ACQ_RESULT_DEP_A (0x0015).
--
-- Deprecated.
data MsgAcqResultDepA = MsgAcqResultDepA
  { _msgAcqResultDepA_snr :: Float
    -- ^ SNR of best point. Currently dimensonless, but will have units of dB Hz
    -- in the revision of this message.
  , _msgAcqResultDepA_cp :: Float
    -- ^ Code phase of best point
  , _msgAcqResultDepA_cf :: Float
    -- ^ Carrier frequency of best point
  , _msgAcqResultDepA_prn :: Word8
    -- ^ PRN-1 identifier of the satellite signal for which acquisition was
    -- attempted
  } deriving ( Show, Read, Eq )

instance Binary MsgAcqResultDepA where
  get = do
    _msgAcqResultDepA_snr <- getFloat32le
    _msgAcqResultDepA_cp <- getFloat32le
    _msgAcqResultDepA_cf <- getFloat32le
    _msgAcqResultDepA_prn <- getWord8
    return MsgAcqResultDepA {..}

  put MsgAcqResultDepA {..} = do
    putFloat32le _msgAcqResultDepA_snr
    putFloat32le _msgAcqResultDepA_cp
    putFloat32le _msgAcqResultDepA_cf
    putWord8 _msgAcqResultDepA_prn

$(deriveSBP 'msgAcqResultDepA ''MsgAcqResultDepA)

$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_msgAcqResultDepA_" . stripPrefix "_msgAcqResultDepA_"}
             ''MsgAcqResultDepA)
$(makeLenses ''MsgAcqResultDepA)

-- | AcqSvProfile.
--
-- Profile for a specific SV for debugging purposes The message describes SV
-- profile during acquisition time. The message is used to debug and measure
-- the performance.
data AcqSvProfile = AcqSvProfile
  { _acqSvProfile_job_type :: Word8
    -- ^ SV search job type (deep, fallback, etc)
  , _acqSvProfile_status   :: Word8
    -- ^ Acquisition status 1 is Success, 0 is Failure
  , _acqSvProfile_cn0      :: Word16
    -- ^ CN0 value. Only valid if status is '1'
  , _acqSvProfile_int_time :: Word8
    -- ^ Acquisition integration time
  , _acqSvProfile_sid      :: GnssSignal
    -- ^ GNSS signal for which acquisition was attempted
  , _acqSvProfile_bin_width :: Word16
    -- ^ Acq frequency bin width
  , _acqSvProfile_timestamp :: Word32
    -- ^ Timestamp of the job complete event
  , _acqSvProfile_time_spent :: Word32
    -- ^ Time spent to search for sid.code
  , _acqSvProfile_cf_min   :: Word32
    -- ^ Doppler range lowest frequency
  , _acqSvProfile_cf_max   :: Word32
    -- ^ Doppler range highest frequency
  , _acqSvProfile_cf       :: Word32
    -- ^ Doppler value of detected peak. Only valid if status is '1'
  , _acqSvProfile_cp       :: Word32
    -- ^ Codephase of detected peak. Only valid if status is '1'
  } deriving ( Show, Read, Eq )

instance Binary AcqSvProfile where
  get = do
    _acqSvProfile_job_type <- getWord8
    _acqSvProfile_status <- getWord8
    _acqSvProfile_cn0 <- getWord16le
    _acqSvProfile_int_time <- getWord8
    _acqSvProfile_sid <- get
    _acqSvProfile_bin_width <- getWord16le
    _acqSvProfile_timestamp <- getWord32le
    _acqSvProfile_time_spent <- getWord32le
    _acqSvProfile_cf_min <- getWord32le
    _acqSvProfile_cf_max <- getWord32le
    _acqSvProfile_cf <- getWord32le
    _acqSvProfile_cp <- getWord32le
    return AcqSvProfile {..}

  put AcqSvProfile {..} = do
    putWord8 _acqSvProfile_job_type
    putWord8 _acqSvProfile_status
    putWord16le _acqSvProfile_cn0
    putWord8 _acqSvProfile_int_time
    put _acqSvProfile_sid
    putWord16le _acqSvProfile_bin_width
    putWord32le _acqSvProfile_timestamp
    putWord32le _acqSvProfile_time_spent
    putWord32le _acqSvProfile_cf_min
    putWord32le _acqSvProfile_cf_max
    putWord32le _acqSvProfile_cf
    putWord32le _acqSvProfile_cp
$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_acqSvProfile_" . stripPrefix "_acqSvProfile_"}
             ''AcqSvProfile)
$(makeLenses ''AcqSvProfile)

msgAcqSvProfile :: Word16
msgAcqSvProfile = 0x001E

-- | SBP class for message MSG_ACQ_SV_PROFILE (0x001E).
--
-- The message describes all SV profiles during acquisition time. The message
-- is used to debug and measure the performance.
data MsgAcqSvProfile = MsgAcqSvProfile
  { _msgAcqSvProfile_acq_sv_profile :: [AcqSvProfile]
    -- ^ SV profiles during acquisition time
  } deriving ( Show, Read, Eq )

instance Binary MsgAcqSvProfile where
  get = do
    _msgAcqSvProfile_acq_sv_profile <- whileM (liftM not isEmpty) get
    return MsgAcqSvProfile {..}

  put MsgAcqSvProfile {..} = do
    mapM_ put _msgAcqSvProfile_acq_sv_profile

$(deriveSBP 'msgAcqSvProfile ''MsgAcqSvProfile)

$(deriveJSON defaultOptions {fieldLabelModifier = fromMaybe "_msgAcqSvProfile_" . stripPrefix "_msgAcqSvProfile_"}
             ''MsgAcqSvProfile)
$(makeLenses ''MsgAcqSvProfile)
