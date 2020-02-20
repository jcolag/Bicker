import React from "react";
import PropTypes from "prop-types";
import ReplyForm from "./ReplyForm";

class PuncButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      callback: this.props.callback,
      count: this.props.count,
      offset: this.props.offset,
      pid: this.props.pid,
      pnumber: this.props.pnumber,
      punc: this.props.punc,
    };
  }

  asMarkup(text) {
    return { __html: text };
  }

  render () {
    const html = this.asMarkup(this.state.punc);
    const name = `${this.state.pnumber}-${this.state.count}`;
    return (
      <React.Fragment>
        <a
          className='punctuation-button'
          name={name}
          offset={this.state.offset}
          onClick={toggleReplyForm}
          title="Click to reply here"
        >
          <span
            dangerouslySetInnerHTML={html}
            name={name}
            offset={this.state.offset}
          />
        </a>
        <ReplyForm
          callback={this.state.callback}
          count={this.state.count}
          offset={this.state.offset}
          pid={this.state.pid}
          pnumber={this.state.pnumber}
        />
      </React.Fragment>
    );
  }
}

PuncButton.propTypes = {
  callback: PropTypes.func,
  count: PropTypes.number,
  offset: PropTypes.number,
  pid: PropTypes.number,
  pnumber: PropTypes.number,
  punc: PropTypes.string,
};
export default PuncButton
